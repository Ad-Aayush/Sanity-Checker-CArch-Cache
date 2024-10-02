import os
import shutil
import zipfile
import subprocess
import threading
import select
import fcntl
import difflib
import regex as re
import json

def set_nonblocking(fd):
    """Set the file descriptor to non-blocking mode."""
    flags = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)
def unzip_to_custom_dir(zip_file, custom_dir):
    """Unzips the given file into a custom directory inside Lab_4_Sanity_Check."""
    if not os.path.exists(custom_dir):
        os.makedirs(custom_dir)
    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(custom_dir)

    if (len(os.listdir(custom_dir)) == 1):
        
        folder_paths = os.listdir(custom_dir)
        folder_paths = os.path.join(custom_dir,folder_paths[0])
        if os.path.isdir(folder_paths):
        # Move contents of the folder to custom_dir
            for item in os.listdir(folder_paths):
                item_path = os.path.join(folder_paths, item)
                shutil.move(item_path, custom_dir)
            os.rmdir(folder_paths)
            
    return custom_dir

def check_required_files(directory, config_path="config.json"):
    """Checks if the necessary files exist in the given directory based on updated rules."""

    try:
        with open(config_path, "r") as config_file:
            required_files = json.load(config_file)["necessary_files"]
    except FileNotFoundError:
        print(f"Config file '{config_path}' not found.")
        exit_gracefully()
    except json.JSONDecodeError:
        print(f"Error parsing the config file '{config_path}'.")
        exit_gracefully()

    try:
        files_in_dir = os.listdir(directory)
    except FileNotFoundError:
        print(f"Directory '{directory}' not found.")
        exit_gracefully()

    files_in_dir_lower = [f.lower() for f in files_in_dir]

    found = [False] * len(required_files)

    for i, (required_file, rules) in enumerate(required_files.items()):
        req_array = files_in_dir_lower if 'rule' in rules and rules['rule'] == 'lowercase' else files_in_dir
        req_file = required_file.lower() if 'rule' in rules and rules['rule'] == 'lowercase' else required_file
        if 'allowed' in rules:
            for allowed_file in rules['allowed']:
                if allowed_file in files_in_dir:
                    found[i] = True
                    break
        elif 'allowed_ext' in rules:
            for file in req_array:
                name, ext = os.path.splitext(file)
                ext = ext[1:]  

                if (name == req_file and ext in rules['allowed_ext']):
                    found[i] = True
                    break

    for i, (required_file, is_found) in enumerate(zip(required_files, found)):
        if not is_found:
            print(f"Required file '{required_file}' missing or doesn't meet the required rules.")
            exit_gracefully()

    return True

outputs = []
def handle_process(commands):
    try:
        # Start the process
        process = subprocess.Popen(
            ["./submission_files/riscv_sim"], 
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1  # Unbuffered for real-time communication
        )
        set_nonblocking(process.stdout.fileno())
        set_nonblocking(process.stderr.fileno())

        # Set stdin and stdout as non-blocking using select
        process.stdout.fileno()
        
        # Loop through commands and send them to the process
        for command in commands:
            process.stdin.write(command + '\n')
            process.stdin.flush()
            output_accumulated = ""
            while True:
                readable, _, _ = select.select([process.stdout, process.stderr], [], [], 0.1)

                if process.stdout in readable:
                    try:
                        output = process.stdout.read()
                        if output:
                            output_accumulated += output
                        else:
                            break  # Break if there's no more output
                    except Exception as e:
                        print(f"Error reading stdout: {e}")
                        exit_gracefully()

                if process.stderr in readable:
                    try:
                        error_output = process.stderr.read()
                        if error_output:
                            print(f"Error from process: {error_output}")
                    except Exception as e:
                        print(f"Error reading stderr: {e}")
                        exit_gracefully()

                # Check if there's more to read
                if not readable:
                    break
            outputs.append(output_accumulated)
            # Check if the process has finished after each command
            if process.poll() is not None:
                break

    except Exception as e:
        print(f"Error handling process: {e}")
        exit_gracefully()
    finally:
        try:
            process.terminate()
            # print(f"Terminated process with PID {process.pid}")
            return outputs
        except Exception as e:
            print(f"Error terminating process: {e}")
            exit_gracefully()
    return outputs

def run_interactive_cpp( inputs, expected_output, input_folder=None, test_type=None):
    """Compiles and runs the C++ file interactively, sending inputs and capturing output."""

    print("Running test case: ", input_folder)
    # process = subprocess.Popen(f"submission_files/{executable}", stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    process_thread = threading.Thread(
        target=handle_process,
        args=(inputs,),
        daemon=True
    )
    process_thread.start()
    process_thread.join()  

    with open(expected_output, 'r') as expected_file:
        expected_lines = expected_file.readlines()
    outputs_cleaned = [line.strip().lower() for entry in outputs if entry for line in entry.split('\n') if line]
    expected_lines = [line.strip().lower() for line in expected_lines if line.strip() != '']
    ## Writing a diff report
    diffReporter = difflib.HtmlDiff()
    html_diff = diffReporter.make_file(expected_lines, outputs_cleaned) 
    with open(f"diffs/{test_type}/{input_folder}.html", "w", encoding="utf-8") as f:
        f.write(html_diff)
    seq_match = difflib.SequenceMatcher(None, expected_lines, outputs_cleaned)
    ratio = seq_match.ratio()
    ## Comparing the outputs
    if ratio == 1.0:
        return True
    else:
        # print(f"Output mismatch. Expected: {expected_lines}, Got: {outputs_cleaned}")
        return False

def exit_gracefully():
    shutil.rmtree("submission_files")
    print("Exiting.")
    exit(0)

def main(zip_file, tests_folder):

    custom_dir = "submission_files"

    unzip_to_custom_dir(zip_file, custom_dir)
    
    list_of_files = os.listdir(custom_dir)
  
    if len(list_of_files) == 1 and os.path.isdir(os.path.join(custom_dir, list_of_files[0])):
        custom_dir = os.path.join(custom_dir, list_of_files[0])
        list_of_files = os.listdir(custom_dir)

    global run_type
    if run_type != None:
        files_check = check_required_files(custom_dir)

        if files_check:
            print("All Required Files Present\n")
    

    if True:
        compile_command = "make"
        compile_process = subprocess.run(
        compile_command, 
        shell=True, 
        cwd="submission_files", 
        stdout=subprocess.PIPE,  # Redirect stdout to /dev/null
        stderr=subprocess.PIPE   # Redirect stderr to /dev/null
        )   
        if compile_process.returncode != 0:
            print(f"Compilation failed. MakeFile returned {compile_process.returncode}\n")
            exit_gracefully()
        elif "riscv_sim" not in os.listdir("submission_files"): # checking for the executable name
            # print(f"Compilation successful for {cpp_file}")
            print(f"Incorrect executable format. Executable should be named riscv_sim\n")
            exit_gracefully()
        TestGroup = os.listdir(tests_folder)

        for test_type in TestGroup:
            each_test_type_folder_path = os.path.join(tests_folder, test_type)
            test_cases = os.listdir(each_test_type_folder_path)
            subprocess.run(["mkdir", "-p", f"diffs/{test_type}"])
            print(test_type)
            for test in test_cases:
                each_test_case_folder_path = os.path.join(each_test_type_folder_path, test)
                test_cases = os.listdir(each_test_case_folder_path)
                input_file = os.path.join(each_test_case_folder_path,"test.in")
                output_file = os.path.join(each_test_case_folder_path, "test.out")

                with open(input_file, 'r') as infile:
                    inputs = [line.strip() for line in infile.readlines()]

                success = run_interactive_cpp( inputs, output_file, test, test_type)

                if success:
                    print(f"Test case {test_type+'/'+test} passed.")
                else:
                    print(f"Test case {test_type+'/'+test} failed.")
                outputs.clear()
                print()
                    
    exit_gracefully()

import sys
run_type  = None

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python3 test_public.py <path_to_submission_zip>")
        exit(1)
        
    if len(sys.argv) == 3:
        run_type = sys.argv[2]
    subprocess.run (["rm" ,"-rf", "diffs"])
    zip_file = sys.argv[1]
    subprocess.run(["mkdir", "-p", "diffs"])
    tests_folder = os.path.join(os.path.dirname(__file__), "Tests")
    main(zip_file, tests_folder)

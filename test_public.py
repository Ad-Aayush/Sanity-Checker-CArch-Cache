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

def check_required_files(directory):
    """Checks if either a .pdf, a .md or a .txt file exists in the given directory."""
    
    has_cpp = False
    required_files = json.load(open("config.json"))["necessary_files"]
    contains = [False]*len(required_files)
    for file in os.listdir(directory):
        if file.endswith('.cpp'):
            has_cpp = True
        for i, required_file in enumerate(required_files):
            if file == required_file:
                contains[i] = True

    if not has_cpp:
        print("The Folder Probably contains no Source Code File\nExiting...")
        exit_gracefully()
    
    for i, required_file in enumerate(required_files):
        if not contains[i]:
            print(f"Required file {required_file} missing.\nExiting...")
            exit_gracefully()
    return True

outputs = []
def handle_process(commands):
    try:
        # Start the process
        process = subprocess.Popen(
            ["./submission_files/test_submission"], 
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

def run_interactive_cpp(cpp_file, inputs, expected_output, input_folder=None, test_type=None):
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
    outputs_cleaned = [line.strip() for entry in outputs if entry for line in entry.split('\n') if line]
    expected_lines = [line.strip() for line in expected_lines if line.strip() != '']
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

    files_check = check_required_files(custom_dir)

    if files_check:
        print("All Required Files Present\n")
    
    cpp_files = [f for f in os.listdir(custom_dir) if f.endswith('.cpp')]

    if len(cpp_files) > 1:
        print("Multiple C++ files found. Aborting.")
        exit_gracefully()
    else:
        cpp_file_path = os.path.join(custom_dir, cpp_files[0])

        compile_command = "make"
        compile_process = subprocess.run(
        compile_command, 
        shell=True, 
        cwd="submission_files", 
        stdout=subprocess.PIPE,  # Redirect stdout to /dev/null
        stderr=subprocess.PIPE   # Redirect stderr to /dev/null
        )   
        if compile_process.returncode != 0:
            print(f"Compilation failed for {cpp_file_path}")
            exit_gracefully()
        elif "test_submission" not in os.listdir("submission_files"):
            # print(f"Compilation successful for {cpp_file}")
            print(f"Incorrect executable name obtained on running make\n")
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

                success = run_interactive_cpp(cpp_file_path, inputs, output_file, test, test_type)

                if success:
                    print(f"Test case {test_type+'/'+test} passed.")
                else:
                    print(f"Test case {test_type+'/'+test} failed.")
                outputs.clear()
                print()
                    
    exit_gracefully()

import sys
if __name__ == "__main__":
    
    if len(sys.argv) != 2:
        print("Usage: python3 test_public.py <path_to_submission_zip>")
        exit(1)
    subprocess.run (["rm" ,"-rf", "diffs"])
    zip_file = sys.argv[1]
    subprocess.run(["mkdir", "-p", "diffs"])
    tests_folder = os.path.join(os.path.dirname(__file__), "Tests")
    main(zip_file, tests_folder)

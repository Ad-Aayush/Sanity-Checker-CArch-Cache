### Computer Architecture
This is a simple sanity check to ensure that your submission format is correct. Before submitting you Lab, ensure that all the tests pass. If any test fails, re-read the lab requirements and ensure that you have followed all instructions.
### Prerequisites
- Make sure you have `python3` installed on your system.
- Install `flex` using the following command:
  ```bash
  sudo apt install flex
  ```
  For MacOS:
  ```bash
  brew install flex
  ```
  
### Using the tester

- Clone the repository using the command:
  ```
   git clone "https://github.com/DikshantK2004/Sanity-Checker-CArch"
  ```
- Place your submission zip in the same folder as the cloned directory.
- For running the tester, on your submission zip file named `xy.zip`, run the following command:
  ```bash
  make test file_name="xy.zip"
  ```
  This command only runs the tests and does not check for the naming conventions or necessary deliverables. It runs the code and generates the diff files.

- Before final submission of your assignment, run the following command:
  ```bash
  make run file_name="xy.zip"
  ```
  The above command will check for all the expected deliverables as mentioned in the assignment, along with their naming convention and the code's correctness. 

- For cleaning the diff logs and the temporary files, run the following command:
  ```bash
  make clean
  ```

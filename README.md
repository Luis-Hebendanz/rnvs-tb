# RNVS Testbench suite

A set of tools allowing the automated testing in docker containers of students submissions to the ISIS platform.


## Installation
You need to install the testbench system-wide (since they need to be run as root):
```bash
sudo -H pip install -e . # install as symlink
```

## Getting submissions
You can of course download them manually and sort/extract them yourself but its much easier to use the [tubtools](https://gitlab.tubit.tu-berlin.de/bongo0594/tubtools):

```bash
pip install git+https://gitlab.tubit.tu-berlin.de/bongo0594/tubtools.git
mkdir rnvs-submissions 
cd rnvs-submissions
isis dl -a 21032 # Downloads all submissions to all assignments of the current ISIS course
```

## Usage
If you installed the package the tests are directly added to your path and can run like this:

```bash
sudo tb-block2 -f T25G01 
```

**NOTE:** This assumes that all submissions are located under `assignment/submissions`. 
Also the results will be written `testresults`.
We might make that configurable in the future.


### Creating tests for submissions

To create a set of tests you need to write a python module in the tests folder. 
The module should call `rnvs_tb.run_tests()` with the exact name of the assignment to be tested.
This will first run the so called  `Compiletest`, which looks for Makefiles or CmakeLists.txt and tries to compile the submitted code in a Docker container. 
Afterwards the `Compiletests` checks if Make/Cmake generated the required files, which need to be specified in the subclass, e.g.:

```python
import rnvs_tb
import docker

ASSIGNMENT = 'Abgabe Foo'

class FooTestCase(rnvs_tb.TKNTestCase):
    expected_files = ['server']

    def test_fail(self):
        self.fail()

def main():
    cli = docker.from_env()
    cli.volumes.create('source_code_vol') # This volume is used to copy students code into the test environment
    rnvs_tb.run_tests(ASSIGNMENT, 'source_code_vol')
``` 

After compilation is finished `rnvs_tb.run_tests` looks for subclasses of `rnvs_tb.TKNTestCase` (actually any unittest.TestCase) in the calling module and runs every method as test which starts with the prefix "test".
For each submission the current path to the source code can be accessed through the class variable `TKNTestCase.path` and the group name is written to `TKNTestCase.group`. 

After all tests completed an individual log is written to `testresults/[group]/compile.log` and `testresults/[group]/test.log`, respectively. A summary can be found in `testresults/results.csv`.

## Troubleshooting

TODO



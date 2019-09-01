import unittest
import sys

from sos_notebook.test_utils import sos_kernel
from ipykernel.tests.utils import execute, wait_for_idle, assemble_output

@unittest.skipIf(sys.platform == 'win32', 'octave does not exist on win32')
class TestSoSKernel(unittest.TestCase):
    def testKernel(self):
        with sos_kernel() as kc:
            execute(kc=kc, code='a = 1')
            stdout, stderr = assemble_output(kc.iopub_channel)
            self.assertEqual(stdout.strip(), '', f'Stdout is not empty, "{stdout}" received')
            self.assertEqual(stderr.strip(), '', f'Stderr is not empty, "{stderr}" received')
            execute(kc=kc, code='%use Octave\n%get a\na')
            stdout, stderr = assemble_output(kc.iopub_channel)
            self.assertEqual(stderr.strip(), '', f'Stderr is not empty, "{stderr}" received')
            self.assertEqual(stdout.strip(), 'a =  1', f'Stdout should be a =  1, "{stdout}" received')

if __name__ == '__main__':
    unittest.main()

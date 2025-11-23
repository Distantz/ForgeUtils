import sys
import os

from pathlib import Path
if len(sys.argv) < 4:
    print("First argument needs to be the path to Cobra Tools! Second argument needs to be the game name! Third argument needs to be a path to an .ovlpaths file!")
    exit(-1)

cobratools = sys.argv[1]
gamestr = sys.argv[2]
ovlpaths = None

print(f"Cobra tools path: {cobratools}")
sys.path.append(cobratools)
from utils.logs import logging_setup # type: ignore
import logging
logging_setup("pack_tool_cmd")

with open(sys.argv[3], "r", ) as file:
    ovlpaths = file.read().splitlines()

from generated.formats.ovl import OvlFile # type: ignore
from utils.config import Config # type: ignore

import contextlib
from modules.formats.shared import DummyReporter # type: ignore

class BuildReporter(DummyReporter):
    def __init__(self):
        self.warnings = []
        self.errors = []
        self.error_files = []

    def show_warning(self, msg: str):
        self.warnings.append(msg)

    def show_error(self, exception: Exception):
        self.errors.append(exception)

    def iter_progress(self, iterable, message, cond=True):
        for item in iterable:
            yield item

    @contextlib.contextmanager
    def report_error_files(self, operation):
        yield self.error_files
        pass
        

config = Config(cobratools)
config.load()

ovl_data = OvlFile()
ovl_data.cfg = config
ovl_data.game = gamestr
ovl_data.load_hash_table()
ovl_data.reporter = BuildReporter()

for path in ovlpaths:

    # convert path to actual path (consistent formatting)
    ovl_path = Path(path).resolve()

    if not ovl_path.exists():
        logging.error(f"OVL path \"{ovl_path.resolve()}\" is not a folder!")
        exit(-1)

    ovl_dest = Path(f"{str(ovl_path)}.ovl").resolve()

    try:
        ovl_data.clear()
        ovl_data.create(path)
        ovl_data.save(ovl_dest)
        if len(ovl_data.reporter.error_files) > 0:
            error_files_str = "\n".join(ovl_data.reporter.error_files)
            raise Exception(f"Ovl packing had errors in some files:\n{error_files_str}\n")
    except Exception as e:
        import traceback
        logging.error(f"Could not create OVL from \"{path}\":\n{e}\n\ntraceback: {traceback.format_exc()}")
        exit(-1)
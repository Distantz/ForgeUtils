import sys
import os

from pathlib import Path
if len(sys.argv) < 4:
    print("First argument needs to be the path to Cobra Tools! Second argument needs to be the game name! Third argument needs to be a path to an .ovlpaths file!")
    exit(-1)

cobratools = sys.argv[1]
gamestr = sys.argv[2]
ovlpaths = None

sys.path.append(cobratools)
from ovl_util.logs import logging_setup # type: ignore
import logging
logging_setup("pack_tool_cmd")

with open(sys.argv[3], "r", ) as file:
    ovlpaths = file.read().splitlines()

from generated.formats.ovl import OvlFile # type: ignore
from ovl_util.config import Config # type: ignore

config = Config(cobratools)
config.load()

ovl_data = OvlFile()
ovl_data.cfg = config
ovl_data.game = gamestr
ovl_data.load_hash_table()

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
    except Exception as e:
        import traceback
        logging.error(f"Could not create OVL from \"{path}\": {e}, traceback: {traceback.format_exc()}")
        exit(-1)
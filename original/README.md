The files in files/ were downloaded on 2026-09-21 from
https://www.ibiblio.org/pub/academic/computer-science/history/pdp-11/rsx/decus/rsx82b/351130/
They were all originally timestamped 1983-04-06.

For the original README, see files/readme.1st

The sources are contained in the RSX-11M universal library files/adv.ulb.
Gunther Schmidl extracted them on 2026-09-18 using the script in this
directory, which was produced with help from an LLM, and sent them via email.
You can reproduce them this way:

    python extract-from-ulb.py files/adv.ulb extracted-source

The sources in ../src/omsi are these files with lower-case names and the
form feeds removed, otherwise unchanged.

The Pascal files are internally dated by code comments, all ranging
from 17-SEP-80 to 12-NOV-80, except for VERBS2.PAS (26-MAY-81) and
TRAVEL.PAS (29-OCT-81).

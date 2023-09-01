#!/usr/bin/env python3

import os
import glob
import sys
import mdocfile
from emtable import Table


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"Usage: {os.path.basename(sys.argv[0])} <mdoc path> <particles_or_micrographs.star>")

    mdoc_dir = os.path.abspath(sys.argv[1])
    star_file = sys.argv[2]

    mic_dict = {}
    mdoc_files = glob.glob(mdoc_dir + "/*.mdoc")

    for fn in mdoc_files:
        df = mdocfile.read(fn)
        mrc_name = os.path.basename(fn).replace(".mdoc", "")
        assert mrc_name == str(df["ImageFile"][0])
        basename, first, last = os.path.basename(mrc_name).split(".")[0].split("_")

        filenames = [basename + "_" + str(z + int(first)) + "_sr.mrc" for z in df["ZValue"]]
        positions = [pos[0] for pos in df["MultishotHoleAndPosition"]]

        mic_dict.update(dict(zip(filenames, positions)))

    clusters = set(mic_dict.values())
    optics_groups = dict(zip(clusters, range(1, len(clusters) + 1)))
    print(optics_groups)

    # work on star file
    optics = Table(fileName=star_file, tableName="optics")
    optics_values = optics[0]
    optics.clearRows()

    try:
        table = "particles"
        input_star = Table(fileName=star_file, tableName=table)
    except:
        table = "micrographs"
        input_star = Table(fileName=star_file, tableName=table)

    output_star = Table(fileName=star_file, tableName=table)
    output_star.clearRows()

    for row in input_star:
        micName = os.path.basename(row.rlnMicrographName)
        if micName in mic_dict:
            #print(micName, mic_dict[micName], optics_groups[mic_dict[micName]])
            new_row = row._replace(rlnOpticsGroup=optics_groups[mic_dict[micName]])
            output_star.addRow(*new_row)

    for grp in optics_groups:
        new_row = optics_values._replace(rlnOpticsGroup=optics_groups[grp],
                                         rlnOpticsGroupName="opticsGroup"+str(optics_groups[grp]))
        optics.addRow(*new_row)

    with open("output.star", "w") as fn:
        optics.writeStar(fn, tableName="optics")
        output_star.writeStar(fn, tableName=table)

    print("Created output.star")

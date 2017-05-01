#!//usr/bin/env python2.7

import subprocess
import re
import sys

baseVersion="2.2.4"
distribution="yakkety"

versionTagRE = re.compile("^v([0-9]+((\.[0-9]+)+))(-(.+))?$")

def collectEntries(baseCommit, baseVersion):
    entries = []

    args = ["git", "log",
            "--format=%h%x09%an%x09%ae%x09%aD%x09%ad%x09%s",
            "--date=format:%Y%m%d.%H%M%S",
            "--author-date-order", "--reverse"]
    try:
        output = subprocess.check_output(args + [baseCommit + ".."])
    except:
        output = subprocess.check_output(args)

    for line in output.splitlines():
        (commit, name, email, date, revdate, subject) = line.split("\t")

        for tag in subprocess.check_output(["git", "tag",
                                            "--points-at",
                                            commit]).splitlines():
            m = versionTagRE.match(tag)
            if m:
                baseVersion = m.group(1)

        entries.append((commit, name, email, date, revdate, subject,
                        baseVersion))

    entries.reverse()

    return entries

def genChangeLogEntries(f, entries, distribution):
    for (commit, name, email, date, revdate, subject, baseVersion) in entries:
        upstreamVersion = baseVersion + "-" + revdate
        version = upstreamVersion + "~" + distribution + "1"
        print >> f, "nextcloud-client (%s) %s; urgency=medium" % (version, distribution)
        print >> f
        print >> f, "  * " + subject
        print >> f
        print >> f, " -- %s <%s>  %s" % (name, email, date)
        print >> f
    return baseVersion

if __name__ == "__main__":
    distribution = sys.argv[2]

    #entries = collectEntries("8aade24147b5313f8241a8b42331442b7f40eef9", "2.2.4")
    entries = collectEntries("dcac71898e7fda7ae4b149e2db25c178c90e7172", "2.3.1")


    with open(sys.argv[1], "wt") as f:
        baseVersion = genChangeLogEntries(f, entries, distribution)
        print baseVersion

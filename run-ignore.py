qbfile = open(".gitignore", "r")

for aline in qbfile:
    print('removing file from git: ', aline)
    bashCommand = "git rm -rf " + aline
    import subprocess
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

qbfile.close()
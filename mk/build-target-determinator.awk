function getdeps(depdir) {
    checked[depdir]++

    # somewhat reliable shell-exec grep for Makefiles referring to what we have
    command = "grep -l 'DEPENDS .*"depdir"' [csn]*/*/Makefile"
    while ((command | getline line) > 0) {
        split(line,path,"/");
        dep[path[1]"/"path[2]]++;
    }
    close(command)
}
function arrlen(arr){
	#synocommunity/spksrc has mawk therefore no length(array), make my own
	for (k in arr) ++count
	return count
}

BEGIN { checked[2]="bogus"; delete checked[2]; dep[2]="bogus"; delete dep[2]; }
/^ (cross|native|spk)\// {
	#only two parts
    split($1,path,"/");
    dep[path[1]"/"path[2]]++;
}

END {
    max_cycles = 30  # avoid infinite loop
    while ((arrlen(checked) < arrlen(dep)) && (max_cycles--)) {
        # easier with re-entrant code :)
        # but instead we loop until the checked == depends
        for (d in dep) {
            # simplified "if (d not in checked) { getdeps(d)}"
            found=0;
            for (c in checked) if (c == d) found++;
            if (1 > found) {
               getdeps(d)
            }
        }
    }
    # print the collected dependents, spk/* only, skipping 4 chars (spk/)
    for (d in dep) if (d ~ "^spk/") print substr(d, 5)
}

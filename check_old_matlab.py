#!/usr/bin/env python3

from subprocess import check_output, CalledProcessError, STDOUT


def from_file(_module_want_check):
    with open("all_modules", "r", errors="replace") as _a:
        for _l in _a:
            modules_list = _l.strip().split()
            for _m in modules_list:
                query_string = 'module whatis {}'.format(_m)  # ["module", "whatis", str(_m)]
                # print(query_string)
                try:
                    module_output = check_output(query_string, shell=True, universal_newlines=True, stderr=STDOUT)
                except CalledProcessError as c:
                    print(c)
                else:
                    if _module_want_check in module_output:
                        print(_m)


def from_command_line(_module_want_check):
    query_string = 'module avail'
    try:
        whole_modules = check_output(query_string, shell=True, universal_newlines=True, stderr=STDOUT)
    except CalledProcessError as c:
        print(c)
    else:
        whole_modules_list = whole_modules.strip().split("----------")
        whole_modules_list = whole_modules_list[-1].strip().split()
        for _m in whole_modules_list:
            query_string = 'module whatis {}'.format(_m)  # ["module", "whatis", str(_m)]
            # print(query_string)
            try:
                module_output = check_output(query_string, shell=True, universal_newlines=True, stderr=STDOUT)
            except CalledProcessError as c:
                print(c)
            else:
                if _module_want_check in module_output:
                    print(_m)


if __name__ == "__main__":
    module_want_check = "matlab_dce_2013b"
    print("\nCheck module: {}\n".format(module_want_check))
    from_command_line(module_want_check)

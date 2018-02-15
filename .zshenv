###############################################################################
# .zshenv is sourced on all invocations of the shell, unless the -f option is set. It should contain commands to set the command search path, plus other important environment variables. `.zshenv' should not contain commands that produce output or assume the shell is attached to a tty.
###############################################################################
# outputting stuff here is bad, it breaks "less help" et.al.
#echo ".zshenv running"

if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    # Windows Subsystem for Linux
    unsetopt BG_NICE
fi
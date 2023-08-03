version = "0.21.2"

local home = os.getenv("HOME")
package.path = home
.. "/.config/xplr/plugins/?/init.lua;"
.. home
.. "/.config/xplr/plugins/?.lua;"
.. package.path

require"icons".setup()
require"map".setup()
require"zoxide".setup()
require"fzf".setup()

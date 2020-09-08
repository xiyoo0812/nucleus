self=false
stds.nucleus = {
    globals = {
        --common
        "ngx",
        "tonubmer", "lfs",
        "string_ex", "table_ex", "math_ex", "util", "coroutine",
        "nucleus", "environ", "signal", "http", "guid", "luabt", "service", "logger", "utility", "data_pack", "shell",
        "import", "class", "interface", "property", "singleton", "super", "implemented", "classof", "is_class", "is_subclass", "instanceof", "conv_class",
    }
}
std = "max+nucleus"
max_cyclomatic_complexity = 12
max_code_line_length = 160
max_comment_line_length = 160
include_files = {
    "server/script/*",
}
ignore = {"212", "213", "512"}


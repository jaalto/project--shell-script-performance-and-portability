#! /bin/sh
# Short: POSIX printf (builtin)
# Desc: Test POSIX support: printf is builtin and not /usr/bin/printf

test ()
{
    case "$(command -v printf)" in
        */*) return 1
        ;;
    esac

    return 0
}

test

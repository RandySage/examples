#! /usr/bin/env python3
"""Simple module/script showing argparse"""

from argparse import ArgumentParser

def get_args():
    """argument parser for argparse_example"""

    parser = ArgumentParser()
    parser.add_argument("--datadir", required=False, type=str,
                        default="/logs/MECS", help="path to data directory")
    parser.add_argument("--threads", "-j", required=False, type=int,
                        help="number of threads", default=5)
    parser.add_argument("--verbose", "-v", required=False,
                        action="store_true",
                        help="used to produce more verbose output")
    args = parser.parse_args()

    return args



def main(args):
    """main function for argparse_example

    splitting the args out separately allows this to be reused in programs"""

    print("The args namespace is {}".format(args))


if __name__ == "__main__":
    args = get_args()
    main(args)

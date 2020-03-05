import argparse


def parse_options():
    parser = argparse.ArgumentParser(usage='''python3 scout_results_summary.py <json_file_path> <aws_cli profile name>''')
    parser.add_argument("file_name", help='the name of the input file')
    parser.add_argument("env", help="the name of your aws_cli profile - generally prod or non-prod")
    args = parser.parse_args()
    return(args)


def main():
    args = parse_options()
    print(args.file_name)
    print(args.env)


if __name__ == '__main__':
    main()
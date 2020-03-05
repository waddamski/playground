from ipwhois import IPWhois
import json
import re
import pprint
import sys

def whois_lookup(addresses):
    results = dict()
    for address in addresses:
        # print("ADDRESS= ", address)
        try:
            obj = IPWhois(address)
            res = obj.lookup_rdap()
            res_array = {'ASN CIDR': res['asn_cidr'], 'CIDR': res['network']['cidr'], 'Organisation': res['asn_description'],  'Net Name': res['network']['name'], 'Parent Handle': res['network']['parent_handle']}
            # results[address] = res_array
        except:
            res_array = {'ADDRESS': address, 'ERROR': 'Unable to lookup this address. Please do it manually'}
        finally:
            results[address] = res_array
    return results


def parse_sg_ip_file(file_name):
    with open(file_name, 'r') as json_file:
        raw_input = json.load(json_file)
        ips = set()
        with open('/tmp/output.txt', 'w') as out:
            pp = pprint.PrettyPrinter(stream=out)
            for line in raw_input:
                pp.pprint(str(line))
        with open('/tmp/output.txt', 'r') as tmp_file:
            for line in tmp_file:
                # ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}\/[0-9]{2}', line)
                ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}', line)
                for thing in ip:
                    clean_ip = thing.replace("[]", "")
                    ips.add(clean_ip)

    return(ips)


def main():
    file_name = sys.argv[1]
    addresses = parse_file(file_name)
    output = whois_lookup(sorted(addresses))
    with open('/tmp/whois_results.json', 'w') as results_file:
        json.dump(output, results_file)
    print('The file /tmp/whois_results.json had been created. Parse it through jq or something similar for prettier viewing.')

# file_name = '../input_files/ec2-security-group-whitelists-aws2.json'
main()
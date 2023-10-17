function sep(title)
{
    print "----------------------------------------------------------------"
    if (title) {
        printf(title)
    }
}

BEGIN {
    status = 0
    in_cert = 0
    cert_cmd = "openssl x509 -text -noout"
    split("", certs)
    c = 0
    cert_fp_cmd = "openssl x509 -fingerprint -noout -in <(echo -e '%s')"
    cert_mod_cmd = "openssl x509 -modulus -noout -in <(echo -e '%s') | openssl md5"

    in_rsa_key = 0
    key_cmd["rsa"] = "openssl rsa -check -noout"
    split("", keys)
    k = 0
    keys_mod_cmd["rsa"] = "openssl rsa -modulus -noout -in <(echo -e '%s') | openssl md5"

    chain_cmd = "openssl verify -partial_chain -show_chain -CAfile <(echo -e '%s') <(echo -e '%s')"
}

/^-----BEGIN CERTIFICATE-----/ {
    in_cert = 1
}

/^-----END CERTIFICATE-----/ {
    sep("Found certificate:\n")
    in_cert = 0
    certs[c] = certs[c] $0
    print certs[c]
    print certs[c] | cert_cmd
    close(cert_cmd)
    c = c + 1
}

/^-----BEGIN RSA PRIVATE KEY-----/ {
    in_rsa_key = 1
}

/^-----END RSA PRIVATE KEY-----/ {
    sep("Found RSA key:\n")
    in_rsa_key = 0
    keys["rsa"][k] = keys["rsa"][k] $0
    print keys["rsa"][k]
    print keys["rsa"][k] | key_cmd["rsa"]
    close(key_cmd["rsa"])
    k = k + 1
}

in_cert {
    certs[c] = certs[c] $0 "\n"
}

in_rsa_key {
    keys["rsa"][k] = keys["rsa"][k] $0 "\n"
}

END {
    success = 1
    split("", errors)
    if (length(certs)) {
        sep(sprintf("Checking chain for %i certs: ", length(certs)))
    }

    for (i=0; i < length(certs) - 1; i++) {
        c1 = certs[i]
        c2 = certs[i+1]

        cmd = sprintf(cert_fp_cmd, c1)
        cmd | getline fp_1
        close(cmd)

        cmd = sprintf(cert_fp_cmd, c2)
        cmd | getline fp_2
        close(cmd)

        cmd = sprintf(chain_cmd, c2, c1)
        cmd | getline out
        close(cmd)

        if (out ~ /OK$/) {
            errors[i] = sprintf("SUCCESS: %s is signed by %s", fp_1, fp_2)
        } else {
            errors[i]= sprintf("FAILED: %s not signed by %s", fp_1, fp_2)
            success = 0
            status = 1
        }
    }

    if (success) {
        print "SUCCESS"
    } else {
        print "FAILED"
    }

    for (i in errors) {
        print errors[i]
    }

    if (length(keys["rsa"]) && length(certs)) {
        sep("Checking if certificate matches the key: ")
        cmd = sprintf(cert_mod_cmd, certs[0])
        cmd | getline c_mod
        close(cmd)

        cmd = sprintf(keys_mod_cmd["rsa"], keys["rsa"][0])
        cmd | getline k_mod
        close(cmd)

        if (k_mod == c_mod) {
            print "SUCCESS"
        } else {
            print "FAILED"
        }

        print "Certificate modulus: " c_mod
        print "Key modulus:         " k_mod
    }

    exit(status)
}

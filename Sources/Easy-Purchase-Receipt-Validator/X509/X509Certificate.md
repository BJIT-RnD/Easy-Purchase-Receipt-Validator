// MARK a sample X.509 certificate.
SEQUENCE{
        SEQUENCE{
            CONTEXTSPECIFIC(0){
                INTEGER: 1 bytes
            }
            INTEGER: 1 bytes
            SEQUENCE{
                OBJECTIDENTIFIER: 1.2.840.113549.1.1.5 (sha1WithRSAEncryption)
                NULL
            }
            SEQUENCE{
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.6 (countryName)
                        PRINTABLESTRING: US
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.10 (organizationName)
                        PRINTABLESTRING: Apple Inc.
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.11 (organizationalUnitName)
                        PRINTABLESTRING: Apple Certification Authority
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.3 (commonName)
                        PRINTABLESTRING: Apple Root CA
                    }
                }
            }
            SEQUENCE{
                UTCTIME: 2006-04-25 21:40:36 +0000
                UTCTIME: 2035-02-09 21:40:36 +0000
            }
            SEQUENCE{
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.6 (countryName)
                        PRINTABLESTRING: US
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.10 (organizationName)
                        PRINTABLESTRING: Apple Inc.
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.11 (organizationalUnitName)
                        PRINTABLESTRING: Apple Certification Authority
                    }
                }
                SET{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.4.3 (commonName)
                        PRINTABLESTRING: Apple Root CA
                    }
                }
            }
            SEQUENCE{
                SEQUENCE{
                    OBJECTIDENTIFIER: 1.2.840.113549.1.1.1 (rsaEncryption)
                    NULL
                }
                BITSTRING: 270 bytes
            }
            CONTEXTSPECIFIC(3){
                SEQUENCE{
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.29.15 (keyUsage)
                        BOOLEAN: true
                        OCTETSTRING{
                            BITSTRING: 1 bytes
                        }
                    }
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.29.19 (basicConstraints)
                        BOOLEAN: true
                        OCTETSTRING{
                            SEQUENCE{
                                BOOLEAN: true
                            }
                        }
                    }
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.29.14 (subjectKeyIdentifier)
                        OCTETSTRING{
                            OCTETSTRING: 20 bytes
                        }
                    }
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.29.35 (authorityKeyIdentifier)
                        OCTETSTRING{
                            SEQUENCE{
                                CONTEXTSPECIFIC(0): 20 bytes
                            }
                        }
                    }
                    SEQUENCE{
                        OBJECTIDENTIFIER: 2.5.29.32 (certificatePolicies)
                        OCTETSTRING{
                            SEQUENCE{
                                SEQUENCE{
                                    OBJECTIDENTIFIER: 1.2.840.113635.100.5.1
                                    SEQUENCE{
                                        SEQUENCE{
                                            OBJECTIDENTIFIER: 1.3.6.1.5.5.7.2.1 (cps)
                                            IA5STRING: https://www.apple.com/appleca/
                                        }
                                        SEQUENCE{
                                            OBJECTIDENTIFIER: 1.3.6.1.5.5.7.2.2 (unotice)
                                            SEQUENCE{
                                                VISIBLESTRING: Reliance on this certificate by any party assumes acceptance of the then applicable standard terms and conditions of use, certificate policy and certification practice statements.
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        SEQUENCE{
            OBJECTIDENTIFIER: 1.2.840.113549.1.1.5 (sha1WithRSAEncryption)
            NULL
        }
        BITSTRING: 256 bytes
    }

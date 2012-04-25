#!/usr/bin/perl

require "ec2ops.pl";

my $account = shift @ARGV || "eucalyptus";
my $user = shift @ARGV || "admin";

# need to add randomness, for now, until account/user group/keypair
# conflicts are resolved

$rando = int(rand(10)) . int(rand(10)) . int(rand(10));
if ($account ne "eucalyptus") {
    $account .= "$rando";
}
if ($user ne "admin") {
    $user .= "$rando";
}
$newgroup = "ebsgroup$rando";
$newkeyp = "ebskey$rando";

parse_input();
print "SUCCESS: parsed input\n";

setlibsleep(0);
print "SUCCESS: set sleep time for each lib call\n";

setremote($masters{"CLC"});
print "SUCCESS: set remote CLC: masterclc=$masters{CLC}\n";

discover_emis();
print "SUCCESS: discovered loaded image: current=$current_artifacts{instancestoreemi}, all=$static_artifacts{instancestoreemis}\n";

discover_zones();
print "SUCCESS: discovered available zone: current=$current_artifacts{availabilityzone}, all=$static_artifacts{availabilityzones}\n";

if ( ($account ne "eucalyptus") && ($user ne "admin") ) {
# create new account/user and get credentials
    create_account_and_user($account, $user);
    print "SUCCESS: account/user $current_artifacts{account}/$current_artifacts{user}\n";
    
    grant_allpolicy($account, $user);
    print "SUCCESS: granted $account/$user all policy permissions\n";
    
    get_credentials($account, $user);
    print "SUCCESS: downloaded and unpacked credentials\n";
    
    source_credentials($account, $user);
    print "SUCCESS: will now act as account/user $account/$user\n";
}
# moving along

setfailuretype("script");
print "SUCCESS: set failure mode to: script\n";

# build and install fake CC
build_and_deploy_fakeCC();
print "SUCCESS: built and deployed fake CC\n";

# test fakeCC availability
confirm_fakeCC();
print "SUCCESS: confirmed that fake CC is in place\n";
confirm_fakeCC();
print "SUCCESS: confirmed again that fake CC is in place\n";

# run a bunch of insts
run_fake_instance_scale(100);
print "SUCCESS: ran fake instances\n";

# confirm that they go to running
confirm_fake_instance_scale(100);
print "SUCCESS: confirmed fake instances reported as running\n";

# restore real CC and config
#restore_realCC();
#print "SUCCESS: restored real CC\n";

doexit(0, "EXITING SUCCESS\n");

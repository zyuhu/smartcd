# Load testing library
source t/tap-functions
source bash_arrays
source bash_smartcd

plan_tests 6

# Set up smartcd
mkdir tmphome
oldhome=$HOME
export HOME=$(pwd)/tmphome

# One tier
dir=tmp_dir
mkdir $dir
smartcd_dir=$HOME/.smartcd$(pwd)/$dir
mkdir -p $smartcd_dir

echo -n >$smartcd_dir/bash_enter
output=$(smartcd $dir)
like "${output-_}" "smartcd: running" "smartcd informed user of script execution"
SMARTCD_QUIET=1
output=$(smartcd $dir)
is "_${output-_}_" "__" "quieted output"

cat >$smartcd_dir/bash_enter <<EOF
echo this is a test
EOF
output=$(smartcd $dir)
is "${output-_}" "this is a test" "bash_enter executed successfully"

rm $smartcd_dir/bash_enter
cat >$smartcd_dir/bash_leave <<EOF
echo this is a leaving test
EOF
output=$(smartcd $dir; smartcd ..)
is "${output-_}" "this is a leaving test" "bash_leave executed successfully"

dir2=$dir/another_dir
smartcd_dir2=$smartcd_dir/another_dir
mkdir -p $dir2
mkdir -p $smartcd_dir2
rm $smartcd_dir/bash_leave
echo "echo -n \"1 \"" > $smartcd_dir/bash_enter
echo "echo 2" > $smartcd_dir2/bash_enter
output=$(smartcd $dir2; smartcd ../..)
is "${output-_}" "1 2" "ran two bash_enter scripts in correct order"

rm $smartcd_dir/bash_enter
rm $smartcd_dir2/bash_enter
echo "echo 1" > $smartcd_dir/bash_leave
echo "echo -n \"2 \"" > $smartcd_dir2/bash_leave
output=$(smartcd $dir2; smartcd ../..)
is "${output-_}" "2 1" "ran two bash_leave scripts in correct order"

# Clean up
rm -rf $dir
rm -rf tmphome
export HOME=$oldhome
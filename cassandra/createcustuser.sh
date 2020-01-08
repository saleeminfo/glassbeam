#echo "Type the Login User Name (email address) "
#read uname
p=2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea
echo "First Name"
read fname
echo "Last Name"
read lname

for uname in `/home/saleem/dp/DevOps/imp/prodscripts/cass/users.txt`
do
echo $uname 

echo "INSERT INTO ums.user (email, first_name, last_name, passwd_hash, realm_def, url_def, mps_def, type, validated, is_prospect, org, department, phone, city, country,region,sso, role, wb_user_name, is_external, report_usage, created_on, active, dashboard_admin) VALUES ('$uname', '$fname', '$lname', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea', 'gbpocui.glassbeam.com', 'apps/dist/index.html', 'springpath:springpath:pod', 'GB', true, false, 'glassbeam', '', '', '-', '-','US',false, 'glassbeam', 'glassbeam', false, false, '2016-01-20 04:00:00+0000', true, true);" >> internal_userlist.cql
done

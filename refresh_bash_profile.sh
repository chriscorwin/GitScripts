echo "preparing to refresh your bash profile"

touch "${gitscripts_path}bash_profile_config.overrides"
touch "${gitscripts_path}environment_config.overrides"

source "${gitscripts_path}environment_config.default"
source "${gitscripts_path}environment_config.overrides"

cat "${gitscripts_path}environment_config.default" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config.overrides" > "${gitscripts_path}bash_profile"

cp "${gitscripts_path}bash_profile" "${git_install}bash_profile"
cp "${gitscripts_path}motd" "${git_install}motd"

rm "${gitscripts_path}bash_profile"

source "${git_install}bash_profile"

echo "refreshed your bash profile"
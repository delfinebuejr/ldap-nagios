# ldap-nagios
class library for integrating Nagios to OpenLDAP

This tool was created by the author for personal use as-is and without any guaranties/warranties. The author will not be liable for any damages due to the use of this tool.

This is a tool that is aimed to provide classes that will let a nagios administrator do the following:
    1. Validate if a user account exists in an openldap server.
    2. Check if the user account exists in the nagios config contacts file.
    3. Create a contact definition based on the user account's ldap attributes
    4. Write the contact definition to the nagios config contacs file.
    

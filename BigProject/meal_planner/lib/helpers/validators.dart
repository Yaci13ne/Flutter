String? emailValidatorFct (String? value) { 
     const pattern =  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"; 
      final regex = RegExp(pattern); 
  if (value!.isEmpty) { return "Email Can't be empty ";} 
  else if (!regex.hasMatch(value)) { return 'Enter a valid email address';} 
  return null;   } 



String? pwdValidationFct (String? value) { 
  const pattern =r'^(?=.*[A-Z])(?=.*?[0-9])(?=.*?[ @#\&*~]).{8,}'; 
  final regex = RegExp(pattern); 
  if (value!.isEmpty) { return "Password Can't be empty "; }  
else if (!regex.hasMatch(value)) { return 'The password must be at least 8 characters \n and should contain at least one uppercase, \n one digit, one special character among (@#\&*~)'; } 
  return null; } 
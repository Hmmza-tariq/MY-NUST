import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> sendMail({message, screen, fromEmail, fromName}) async {
  const serviceId = 'service_o1vf1b4';
  const templateId = 'template_axke9pe';
  const userId = '6rerF8krXrFtINTmF';

  var url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  try {
    await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          'template_params': {
            'from_name': fromName,
            'from_email': fromEmail,
            'message': message,
            'screen': screen,
          }
        }));
    return true;
  } catch (error) {
    return false;
  }
}

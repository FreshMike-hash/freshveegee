import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshveegee/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAgreed = false;
  bool _isLoading = false;
  String _errorMessage = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFd7f5d1),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.green),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        width: 80,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create new account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your new account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'Password',
                    isVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      const Text('I agree with the '),
                      GestureDetector(
                        onTap: () {
                          _showTermsAndConditions();
                        },
                        child: const Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ElevatedButton(
                    onPressed: _isAgreed && !_isLoading ? _signUp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Colors.green),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.green,
          ),
          onPressed: onVisibilityToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send a verification email
      await userCredential.user?.sendEmailVerification();

      // Store the user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _isLoading = false;
      });

      // Show the dialog after successful registration and email verification
      _showVerificationDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred. Please try again.";
      });
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Email Sent'),
        content: const Text(
          'A verification email has been sent to your email address. Please check your inbox and follow the instructions to verify your account.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to FreshVeegee! These Terms and Conditions (“Terms”) govern your access to and use of the FreshVeegee mobile application (“App”), which allows you to scan and capture images of fruits and vegetables to determine their freshness. By accessing or using the App, you agree to be bound by these Terms. If you do not agree with these Terms, please do not use the App.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Acceptance of Terms\nBy downloading, installing, or using FreshVeegee, you agree to abide by these Terms. We may update these Terms from time to time, and the updated version will be effective as soon as it is posted in the App. Please review the Terms periodically for any changes.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. Use of the App\nFreshVeegee provides the ability to capture images of fruits and vegetables to detect their freshness. You agree to use the App in accordance with all applicable laws and regulations. You may not use the App for any unlawful purpose or in any way that could harm, disable, or overburden the App.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. Intellectual Property\nAll content, features, and functionality of the App, including the software, text, graphics, logos, and images, are owned by FreshVeegee or its licensors and are protected by copyright and other intellectual property laws. You may not copy, modify, or distribute any content from the App without prior written permission.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. Privacy and Data Collection\nWe value your privacy and are committed to protecting your personal information. For details on how we collect, use, and protect your data, please refer to our Privacy Policy.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '5. Accuracy of Freshness Detection\nThe freshness detection is based on image processing and machine learning algorithms. While we strive to provide accurate results, the detection may not always be perfect. FreshVeegee cannot guarantee the accuracy or reliability of the results, and users should use their judgment in determining the freshness of their produce.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '6. User-Generated Content\nYou may upload images of fruits and vegetables through the App. By uploading images, you grant FreshVeegee a non-exclusive, royalty-free, worldwide license to use, display, and process these images for the purpose of providing the freshness detection feature.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '7. Termination\nWe may suspend or terminate your access to the App at any time for violations of these Terms or for any reason. Upon termination, you must cease all use of the App.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '8. Limitation of Liability\nFreshVeegee is not liable for any indirect, incidental, or consequential damages arising from your use of the App. The App is provided “as-is,” and we make no representations or warranties regarding the accuracy, reliability, or functionality of the App.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '9. Governing Law\nThese Terms are governed by the laws of PHILIPPINES, and any disputes will be subject to the exclusive jurisdiction of the courts in PHILIPPINES.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '10. Contact Us\nIf you have any questions about these Terms or need further information, please contact us at: ',
                style: TextStyle(fontSize: 16),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Email: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'freshveegee@gmail.com',
                      style: TextStyle(
                        backgroundColor: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '\nAddress: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Oroquieta City\nMisamis Occidental\n7207\nPHILIPPINES',
                      style: TextStyle(
                        backgroundColor: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'This Privacy Policy explains how FreshVeegee (“we,” “our,” or “us”) collects, uses, and protects your personal information when you use our mobile application (“App”). By using the App, you agree to the collection and use of information in accordance with this Privacy Policy.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Information We Collect\nWe collect the following types of information when you use FreshVeegee:\nPersonal Information: When you create an account or interact with the App, we may collect personal information such as your name, email address, and other identifiable information.\nUsage Data: We collect data on how you use the App, including the images you upload, interactions with the interface, and other technical data related to your device (e.g., device type, operating system, IP address).\nImages: We collect images you upload of fruits and vegetables for the purpose of freshness detection. These images are used only for processing and improving the freshness detection feature.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. How We Use Your Information\nWe use the information we collect for the following purposes:\nTo provide the freshness detection feature, process images, and deliver accurate results.\nTo improve the App’s functionality and performance.\nTo communicate with you about updates, features, or promotions related to the App.\nTo ensure compliance with legal obligations and terms of service.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. How We Share Your Information\nWe will not share your personal information or images with third parties, except in the following circumstances:\nWith Service Providers: We may share data with trusted third-party service providers who assist in the operation of the App (e.g., cloud storage or analytics providers).\nLegal Compliance: We may disclose your information to comply with legal obligations or in response to lawful requests from authorities.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. Data Retention\nWe retain your personal information and images for as long as necessary to provide the services or as required by law. You may request the deletion of your account and associated data by contacting us at freshveegee@gmail.com.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '5. Security\nWe take reasonable measures to protect your personal information from unauthorized access, alteration, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, so we cannot guarantee absolute security.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '6. Your Rights\nDepending on your jurisdiction, you may have certain rights regarding your personal information, including:\nThe right to access, update, or delete your personal data.\nThe right to withdraw consent for data processing at any time.\nThe right to object to the processing of your data under certain circumstances.\nTo exercise these rights, please contact us at freshveegee@gmail.com.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '7. Children’s Privacy\nFreshVeegee is not intended for children under the age of 13. We do not knowingly collect personal information from children. If we become aware that a child has provided us with personal information, we will take steps to delete such information.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '8. Changes to This Privacy Policy\nWe may update this Privacy Policy from time to time. Any changes will be posted in the App, and the revised policy will be effective immediately upon posting.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '9. Contact Us\nIf you have any questions or concerns regarding this Privacy Policy, please contact us at:',
                style: TextStyle(fontSize: 16),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Email: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'freshveegee@gmail.com',
                      style: TextStyle(
                        backgroundColor: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '\nAddress: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Oroquieta City\nMisamis Occidental\n7207\nPHILIPPINES',
                      style: TextStyle(
                        backgroundColor: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

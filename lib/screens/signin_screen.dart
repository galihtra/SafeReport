import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:safe_report/screens/signup_screen.dart';
import 'package:safe_report/screens/admin_home_screen.dart';
import 'package:safe_report/screens/navigation_bar.dart';
import 'package:safe_report/screens/admin_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isHidden = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 50),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Masuk Akun',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan alamat email',
                        prefixIcon: const Icon(Icons.email),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                          },
                          icon: Icon(isHidden
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                      ),
                      obscureText: isHidden,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        // Aksi ketika tombol ditekan
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          // fetch the user from Firestore using the uid
                          DocumentSnapshot userSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user!.uid)
                                  .get();

                          // check if user is an admin
                          bool isAdmin = userSnapshot['isAdmin'] ?? false;

                          if (isAdmin) {
                            // navigate to admin home screen if user is an admin
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminNavigationBar()),
                            );
                          } else {
                            // navigate to normal user home screen if user is not an admin
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BarNavigation(currentIndex: 0,)),
                            );
                          }
                        } catch (error) {
                          print(error);
                          if (error is FirebaseAuthException) {
                            String errorMessage =
                                error.message ?? "An error occurred";
                            Fluttertoast.showToast(
                                msg: errorMessage, gravity: ToastGravity.TOP);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFEC407A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: const Size(129, 48),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontFamily: 'Inter',
                            ),
                          ),
                          TextSpan(
                            text: 'Daftar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

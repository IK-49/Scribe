import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Scribe/login_pages/login.dart';
import 'package:Scribe/login_pages/sign_up.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          'I already have an account',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      width: MediaQuery.of(context).size.width * 0.75,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              // Solid color background
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Color.fromARGB(255, 58, 73, 238), // Set your preferred solid color here
              ),
              // Positioned large text in the background
              Positioned(
                top: 100,
                left: 100,
                right: 20,
                child: Text(
                  'The\nBest\nWriting\nApp', // The large white text
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 150.0, // Large font size
                    fontFamily: "RubicMonoOne",
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(1), // Transparent white to blend with background
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Spacer(),
                      SizedBox(height: 60.0),
                      // Removed the image
                      SizedBox(height: 100),
                      
                      SizedBox(height: 10.0), // Space between the text and the button
                      _buildSignupBtn(),
                      _buildLoginBtn(),
                      SizedBox(height: 40.0), // Space between the buttons and the bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

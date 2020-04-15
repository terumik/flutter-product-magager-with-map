import 'package:product_manager_with_map/models/auth.model.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:flutter/material.dart';
import 'package:product_manager_with_map/widgets/ui_elements/adaptive_progress_indicators.wodget.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;

  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Email', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email.';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Please enter a password.';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
              labelText: 'Confirm Password',
              filled: true,
              fillColor: Colors.white),
          obscureText: true,
          validator: (String value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.Signup) {
              return 'Password do not match.';
            }
          },
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      title: Text('Accept Terms'),
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildEmailTextField(),
          SizedBox(height: 10.0),
          _buildPasswordTextField(),
          SizedBox(
            height: 10.0,
          ),
          _buildConfirmPasswordTextField(),
          _buildAcceptSwitch(),
          SizedBox(
            height: 10.0,
          ),
          FlatButton(
              onPressed: () {
                if (_authMode == AuthMode.Login) {
                  setState(() {
                    _authMode = AuthMode.Signup;
                  });
                  _animationController.forward();
                } else {
                  setState(() {
                    _authMode = AuthMode.Login;
                  });
                  _animationController.reverse();
                }
              },
              child: Text(
                  'Switch to ${_authMode == AuthMode.Login ? 'Sign-Up' : 'Login'}')),
          SizedBox(
            height: 10.0,
          ),
          ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
            return model.isLoading
                ? AdaptiveProgressIndicators()
                : RaisedButton(
                    child: _authMode == AuthMode.Login
                        ? Text('Login')
                        : Text('Sign-Up'),
                    textColor: Colors.white,
                    onPressed: () {
                      _submitForm(model.authenticate);
                    });
          })
        ],
      ),
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      // todo: display error message?
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInfo;

    successInfo = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (!successInfo['error']) {
//      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(successInfo['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
              child: Container(
            width: targetWidth,
            child: _buildForm(),
          )),
        ),
      ),
    );
  }
}

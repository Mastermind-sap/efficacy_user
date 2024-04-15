import 'package:efficacy_user/config/config.dart';
import 'package:efficacy_user/controllers/controllers.dart';
import 'package:efficacy_user/controllers/services/instituion/institution_controller.dart';
import 'package:efficacy_user/controllers/services/mail/mail_controller.dart';
import 'package:efficacy_user/controllers/services/verification_code/verification_code_controller.dart';
import 'package:efficacy_user/dialogs/loading_overlay/loading_overlay.dart';
import 'package:efficacy_user/models/models.dart';
import 'package:efficacy_user/models/verification_code/verification_code_model.dart';
import 'package:efficacy_user/pages/pages.dart';
import 'package:efficacy_user/pages/signup/widgets/edit_form/edit_form.dart';
import 'package:efficacy_user/pages/signup/widgets/nav_buttons.dart';
import 'package:efficacy_user/pages/signup/widgets/steps.dart';
import 'package:efficacy_user/utils/exit_program.dart';
import 'package:efficacy_user/widgets/snack_bar/error_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  static const String routeName = '/SignUpPage';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageUserDetailsState();
}

class _SignUpPageUserDetailsState extends State<SignUpPage> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController scholarIDController = TextEditingController();
  PhoneNumber? phoneNumber;
  String gdscEmail = "gdsc@example.com";
  String selectedDegree = Degree.BTech.name;
  String selectedBranch = Branch.CSE.name;
  String selectedInstitute = 'NIT Silchar';

  List<String> institutes = [];

  Uint8List? _image;

  Future<void> init() async {
    institutes = (await InstitutionController.getAllInstitutions())
        .map((model) => model.name)
        .toList();
    if (institutes.isNotEmpty) {
      setState(() {
        institutes;
      });
    }
  }

  // Function to launch default email app
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Uri.encodeComponent(gdscEmail),
      query: 'subject=Addition of new club',
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch email');
    }
  }

  int activeStep = 0;
  bool takeStep = false;
  bool verificationCodeVerified = false;

  bool backButtonDisableChecker() {
    return activeStep == 0;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> generateAndSendCode() async {
    await showLoadingOverlay(
        context: context,
        asyncTask: () async {
          if (!(await UserController.doesUserExists(
              email: emailController.text))) {
            VerificationCodeModel verificationCode =
                await VerificationCodeController.generateRandomCodeAndSave(
              len: 5,
              email: emailController.text,
              intent: VerificationCodeIntent.createAccount,
            );
            await MailController.sendVerificationCodeMail(
              code: verificationCode.code,
              email: verificationCode.email,
              expiresAt: verificationCode.expiresAt,
            );
            showSnackBar(context, "Please check your email for the code");
          } else {
            throw Exception("User already exists");
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    //size of screen
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    //size constants
    double gap = height * 0.02;
    double formWidth = width * 0.8;
    double vMargin = width * 0.16;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await showExitWarning(context);
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            margin: EdgeInsets.only(top: vMargin),
            child: SizedBox(
                width: width,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "Hey! Welcome to Efficacy",
                          style: TextStyle(fontSize: 25),
                        ),
                        SignUpSteps(
                          activeStep: activeStep,
                          takeStep: takeStep,
                          onPressedStep: (int step) async {
                            if (_formKey.currentState!.validate() &&
                                (activeStep - step).abs() == 1) {
                              bool canMove = false;
                              if (activeStep != 1) {
                                canMove = true;
                              } else if (step == 0) {
                                canMove = true;
                              } else if (verificationCodeVerified) {
                                canMove = true;
                              }
                              if (canMove) {
                                setState(() {
                                  takeStep = true;
                                  activeStep = step;
                                });
                              }
                            }
                          },
                          onStepReached: (int index) {
                            setState(() {
                              activeStep = index;
                            });
                          },
                        ),
                        SizedBox(
                          width: formWidth,
                          child: EditForm(
                            step: activeStep,
                            verificationCodeVerified: verificationCodeVerified,
                            resendVerificationCode: generateAndSendCode,
                            emailController: emailController,
                            passwordController: passwordController,
                            confirmPasswordController:
                                confirmPasswordController,
                            verificationCodeController:
                                verificationCodeController,
                            nameController: nameController,
                            scholarIDController: scholarIDController,
                            onPhoneChanged: (PhoneNumber newPhoneNumber) {
                              phoneNumber = newPhoneNumber;
                            },
                            onImageChanged: (Uint8List? newImage) {
                              _image = newImage;
                            },
                            selectedDegree: selectedDegree,
                            onDegreeChanged: (String? newSelectedDegree) {
                              if (newSelectedDegree != null) {
                                selectedDegree = newSelectedDegree;
                              }
                            },
                            selectedBranch: selectedBranch,
                            onBranchChanged: (String? newSelectedBranch) {
                              if (newSelectedBranch != null) {
                                selectedBranch = newSelectedBranch;
                              }
                            },
                            institutes: institutes,
                            selectedInstitute: selectedInstitute,
                            onInstituteChanged: (String? newSelectedInstitute) {
                              if (newSelectedInstitute != null) {
                                selectedInstitute = newSelectedInstitute;
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: height * 0.1,
                          width: formWidth,
                          child: SignUpNavButtons(
                            activeStep: activeStep,
                            onPressedBack: (int index) {
                              if (!backButtonDisableChecker()) {
                                setState(() {
                                  --activeStep;
                                });
                              }
                            },
                            onPressedNext: (int index) async {
                              if (_formKey.currentState!.validate()) {
                                if (index == 0 && !verificationCodeVerified) {
                                  await generateAndSendCode();

                                  setState(() {
                                    ++activeStep;
                                  });
                                } else if (index == 1 &&
                                    !verificationCodeVerified) {
                                  await showLoadingOverlay(
                                      context: context,
                                      asyncTask: () async {
                                        await VerificationCodeController
                                            .verifyCode(
                                          code: verificationCodeController.text,
                                          email: emailController.text,
                                          intent: VerificationCodeIntent
                                              .createAccount,
                                        );
                                        verificationCodeVerified = true;

                                        setState(() {
                                          ++activeStep;
                                        });
                                      });
                                } else if (index == 3) {
                                  UserModel? user;
                                  showLoadingOverlay(
                                      context: context,
                                      asyncTask: () async {
                                        UploadInformation? info;
                                        if (_image != null) {
                                          info =
                                              await ImageController.uploadImage(
                                            img: _image!,
                                            name: nameController.text,
                                            folder: ImageFolder.userImage,
                                          );
                                        }
                                        user = await UserController.create(
                                          UserModel(
                                            name: nameController.text,
                                            email: emailController.text,
                                            password: passwordController.text,
                                            scholarID: scholarIDController.text,
                                            userPhoto: info?.url,
                                            userPhotoPublicID: info?.publicID,
                                            phoneNumber: phoneNumber,
                                            branch: Branch.values.firstWhere(
                                                (branch) =>
                                                    branch.name ==
                                                    selectedBranch),
                                            degree: Degree.values.firstWhere(
                                                (degree) =>
                                                    degree.name ==
                                                    selectedDegree),
                                          ),
                                        );
                                      },
                                      onCompleted: () {
                                        if (user != null && mounted) {
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            Homepage.routeName,
                                            (_) => false,
                                          );
                                        }
                                      });
                                } else {
                                  setState(() {
                                    ++activeStep;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              LoginPage.routeName,
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                                text: "Already have an account? ",
                                children: [
                                  TextSpan(
                                      text: "Log In",
                                      style: TextStyle(
                                          color: dark,
                                          decoration: TextDecoration.underline))
                                ],
                                style: TextStyle(color: shadow)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/profile_api_service.dart';
import '../api_services/location_api_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _pincodeController;

  // Selected state and district labels & values
  String? _selectedStateValue;
  String? _selectedStateLabel;
  String? _selectedDistrictValue;
  String? _selectedDistrictLabel;

  List<Map<String, dynamic>> _statesList = [];
  List<Map<String, dynamic>> _districtsList = [];
  bool _isLoadingStates = false;
  bool _isLoadingDistricts = false;
  
  PlatformFile? _pickedFile;
  String? _emailError;
  bool _isSaving = false;
  String? _profileImageUrl;

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailError = null;
      });
      return;
    }
    if (!value.contains('.')) {
      setState(() {
        _emailError = "Email must contain at least one '.' (e.g., .com)";
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _pincodeController = TextEditingController();
    _loadProfileData();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoadingStates = true;
    });
    try {
      final states = await LocationApiService.fetchStates();
      setState(() {
        _statesList = states;
        _isLoadingStates = false;
      });
      _resolveSavedStateAndDistrict();
    } catch (e) {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _loadDistricts(String stateVal) async {
    setState(() {
      _isLoadingDistricts = true;
      _districtsList = [];
    });
    try {
      final districts = await LocationApiService.fetchDistricts(stateVal);
      final bool isTamilNadu = stateVal == '33' || _selectedStateLabel?.toLowerCase().contains('tamil nadu') == true;

      if (districts.isEmpty || (!isTamilNadu && districts.any((d) => d['label'] == 'Salem'))) {
        setState(() {
          _districtsList = _getFallbackDistricts(stateVal);
          _isLoadingDistricts = false;
        });
      } else {
        setState(() {
          _districtsList = districts;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      setState(() {
        _districtsList = _getFallbackDistricts(stateVal);
        _isLoadingDistricts = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackDistricts(String stateNameOrVal) {
    final lower = stateNameOrVal.toLowerCase();
    List<String> dists = [];
    if (lower.contains('goa') || stateNameOrVal == '30') {
      dists = ['North Goa', 'South Goa'];
    } else if (lower.contains('karnataka') || stateNameOrVal == '29') {
      dists = ['Bengaluru', 'Mysore', 'Hubli-Dharwad', 'Mangalore', 'Belgaum', 'Udupi', 'Dharwad', 'Gulbarga'];
    } else if (lower.contains('kerala') || stateNameOrVal == '32') {
      dists = ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Wayanad', 'Ernakulam', 'Kollam', 'Palakkad'];
    } else if (lower.contains('tamil nadu') || stateNameOrVal == '33') {
      dists = ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli', 'Tirunelveli', 'Erode', 'Vellore', 'Namakkal', 'Thanjavur'];
    } else if (lower.contains('maharashtra') || stateNameOrVal == '27') {
      dists = ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad', 'Solapur', 'Amravati'];
    } else if (lower.contains('delhi') || stateNameOrVal == '7') {
      dists = ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi'];
    } else if (lower.contains('andhra') || stateNameOrVal == '37') {
      dists = ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Anantapur', 'Nellore', 'Kurnool', 'Chittoor', 'Kadapa'];
    } else if (lower.contains('telangana') || stateNameOrVal == '36') {
      dists = ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam', 'Ramagundam'];
    } else if (lower.contains('rajasthan') || stateNameOrVal == '8') {
      dists = ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner', 'Alwar', 'Bhilwara'];
    } else if (lower.contains('uttar pradesh') || lower.contains('u.p.') || stateNameOrVal == '9') {
      dists = ['Lucknow', 'Kanpur', 'Noida', 'Ghaziabad', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly'];
    } else if (lower.contains('gujarat') || stateNameOrVal == '24') {
      dists = ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar', 'Bhavnagar', 'Jamnagar'];
    } else if (lower.contains('west bengal') || stateNameOrVal == '19') {
      dists = ['Kolkata', 'Howrah', 'Darjeeling', 'Durgapur', 'Asansol', 'Siliguri', 'Kharagpur'];
    } else if (lower.contains('punjab') || stateNameOrVal == '3') {
      dists = ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali'];
    } else if (lower.contains('haryana') || stateNameOrVal == '6') {
      dists = ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Rohtak', 'Hisar'];
    } else if (lower.contains('bihar') || stateNameOrVal == '10') {
      dists = ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga', 'Purnia'];
    } else if (lower.contains('jammu') || stateNameOrVal == '1') {
      dists = ['Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Kathua', 'Udhampur'];
    } else if (lower.contains('uttarakhand') || stateNameOrVal == '5') {
      dists = ['Dehradun', 'Haridwar', 'Haldwani', 'Roorkee', 'Rishikesh'];
    } else if (lower.contains('himachal') || stateNameOrVal == '2') {
      dists = ['Shimla', 'Dharamshala', 'Manali', 'Kullu', 'Solan', 'Mandi'];
    } else if (lower.contains('jharkhand') || stateNameOrVal == '20') {
      dists = ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'];
    } else if (lower.contains('odisha') || stateNameOrVal == '21') {
      dists = ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Sambalpur', 'Balasore'];
    } else if (lower.contains('chhattisgarh') || stateNameOrVal == '22') {
      dists = ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg'];
    } else if (lower.contains('madhya pradesh') || stateNameOrVal == '23') {
      dists = ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar'];
    } else {
      dists = ['District 1', 'District 2', 'District 3'];
    }

    int idx = 1;
    return dists.map((d) {
      final String val = (100 + idx).toString();
      idx++;
      return {
        'value': val,
        'label': d,
      };
    }).toList();
  }

  void _onStateChanged(Map<String, dynamic> stateItem) {
    setState(() {
      _selectedStateValue = stateItem['value'];
      _selectedStateLabel = stateItem['label'];
      _selectedDistrictValue = null;
      _selectedDistrictLabel = null;
    });
    _loadDistricts(stateItem['value']);
  }

  void _onDistrictChanged(Map<String, dynamic> districtItem) {
    setState(() {
      _selectedDistrictValue = districtItem['value'];
      _selectedDistrictLabel = districtItem['label'];
    });
  }

  Future<void> _onPincodeChanged(String pin) async {
    if (pin.length == 6) {
      final data = await LocationApiService.autofillPincode(pin);
      if (data != null && mounted) {
        final stateName = data['state']?.toString().trim();
        final cityName = data['city']?.toString().trim();
        
        if (stateName != null && stateName.isNotEmpty) {
          final Map<String, dynamic> match = _statesList.firstWhere(
            (s) => s['label'].toString().toLowerCase() == stateName.toLowerCase(),
            orElse: () => <String, dynamic>{},
          );
          if (match.isNotEmpty) {
            setState(() {
              _selectedStateValue = match['value'];
              _selectedStateLabel = match['label'];
            });
            await _loadDistricts(match['value']);
            if (cityName != null && cityName.isNotEmpty) {
              final Map<String, dynamic> distMatch = _districtsList.firstWhere(
                (d) => d['label'].toString().toLowerCase() == cityName.toLowerCase(),
                orElse: () => <String, dynamic>{},
              );
              if (distMatch.isNotEmpty) {
                setState(() {
                  _selectedDistrictValue = distMatch['value'];
                  _selectedDistrictLabel = distMatch['label'];
                });
              } else {
                final newOption = {
                  'value': '999',
                  'label': cityName,
                };
                setState(() {
                  _districtsList.add(newOption);
                  _selectedDistrictValue = newOption['value'];
                  _selectedDistrictLabel = newOption['label'];
                });
              }
            }
          } else {
            // State not found in list, append it dynamically
            final newStateOption = {
              'value': '99',
              'label': stateName,
            };
            final newDistOption = cityName != null && cityName.isNotEmpty ? {
              'value': '999',
              'label': cityName,
            } : null;

            setState(() {
              _statesList.add(newStateOption);
              _selectedStateValue = newStateOption['value'];
              _selectedStateLabel = newStateOption['label'];
              if (newDistOption != null) {
                _districtsList = [newDistOption];
                _selectedDistrictValue = newDistOption['value'];
                _selectedDistrictLabel = newDistOption['label'];
              }
            });
          }
        }
      }
    }
  }

  Future<void> _resolveSavedStateAndDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString('state') ?? '';
    final savedDistrict = prefs.getString('district') ?? '';

    if (savedState.isNotEmpty && _statesList.isNotEmpty) {
      final Map<String, dynamic> stateMatch = _statesList.firstWhere(
        (s) => s['value'].toString() == savedState,
        orElse: () => _statesList.firstWhere(
          (s) => s['label'].toString().toLowerCase() == savedState.toLowerCase(),
          orElse: () => <String, dynamic>{},
        ),
      );
      if (stateMatch.isNotEmpty) {
        setState(() {
          _selectedStateValue = stateMatch['value'];
          _selectedStateLabel = stateMatch['label'];
        });
        await _loadDistricts(stateMatch['value']);
        
        if (savedDistrict.isNotEmpty && _districtsList.isNotEmpty) {
          final Map<String, dynamic> distMatch = _districtsList.firstWhere(
            (d) => d['value'].toString() == savedDistrict,
            orElse: () => _districtsList.firstWhere(
              (d) => d['label'].toString().toLowerCase() == savedDistrict.toLowerCase(),
              orElse: () => <String, dynamic>{},
            ),
          );
          if (distMatch.isNotEmpty) {
            setState(() {
              _selectedDistrictValue = distMatch['value'];
              _selectedDistrictLabel = distMatch['label'];
            });
          } else {
            setState(() {
              _selectedDistrictLabel = savedDistrict;
              _selectedDistrictValue = savedDistrict;
            });
          }
        }
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('name') ?? 'Profile';
      final cachedEmail = prefs.getString('email') ?? 'profile@gmail.com';
      final cachedMobile = prefs.getString('mobile') ?? '98765 43219';
      final cachedAddress = prefs.getString('address') ?? '';
      final cachedPincode = prefs.getString('pincode') ?? '';
      final cachedImage = prefs.getString('profile_image');

      if (mounted) {
        setState(() {
          _nameController.text = cachedName;
          _emailController.text = cachedEmail;
          _phoneController.text = _formatMobile(cachedMobile);
          _addressController.text = cachedAddress;
          _pincodeController.text = cachedPincode;
          _profileImageUrl = cachedImage;
        });
      }

      final result = await ProfileApiService.fetchProfile();
      if (result != null && result['data'] != null && mounted) {
        final data = result['data'];
        setState(() {
          _nameController.text = data['name'] ?? _nameController.text;
          _emailController.text = data['email'] ?? _emailController.text;
          final rawMobile = data['mobile'] ?? data['phone'] ?? cachedMobile;
          _phoneController.text = _formatMobile(rawMobile);
          _addressController.text = data['address'] ?? _addressController.text;
          _pincodeController.text = data['pincode'] ?? _pincodeController.text;
          _profileImageUrl = data['profile_image'] ?? _profileImageUrl;
        });
        _resolveSavedStateAndDistrict();
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  String _formatMobile(String mobile) {
    final text = mobile.replaceAll(RegExp(r'\D'), '');
    final digits = text.substring(0, text.length > 10 ? 10 : text.length);
    if (digits.length > 5) {
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return digits;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase();
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        
        if (extension != null && allowedExtensions.contains(extension)) {
          setState(() {
            _pickedFile = file;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Only image formats (JPG, JPEG, PNG, GIF, BMP, WEBP) are allowed.',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF004AC6),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Blue AppBar (Same header design like Ads/MarketPlace) ──
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable Body with 20px padding matching other screens ──
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24), // Subtle top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Profile Photo Section ──
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: _pickImage,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _pickedFile != null
                                ? (kIsWeb
                                    ? (_pickedFile!.bytes != null
                                        ? Image.memory(
                                            _pickedFile!.bytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/home/mohan_profile.png',
                                            fit: BoxFit.cover,
                                          ))
                                    : (_pickedFile!.path != null
                                        ? Image.file(
                                            File(_pickedFile!.path!),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/home/mohan_profile.png',
                                            fit: BoxFit.cover,
                                          )))
                                : (_profileImageUrl != null && _profileImageUrl!.startsWith('http')
                                    ? Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                          'assets/home/mohan_profile.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/home/mohan_profile.png',
                                        fit: BoxFit.cover,
                                      )),
                          ),
                        ),
                        // Camera Icon Badge
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF004AC6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h), // Subtle spacing

                  // ── KYC Verified Badge ──
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color:  Color(0xFFC3FAE9), // Light green background from user edit
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF009668), // Emerald checkmark
                          size: 20.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'KYC VERIFIED',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF009668),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h), // Subtle spacing

                  // ── Input Fields Section ──
                  _buildInputField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 14.h),

                  _buildInputField(
                    label: 'Email Address',
                    controller: _emailController,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: _validateEmail,
                  ),
                  SizedBox(height: 14.h),

                  _buildInputField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FiveDigitSpaceFormatter()],
                  ),
                  SizedBox(height: 14.h),

                  _buildInputField(
                    label: 'Address (Door No / Street)',
                    controller: _addressController,
                    icon: Icons.home_outlined,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  SizedBox(height: 14.h),

                  _buildInputField(
                    label: 'Pincode',
                    controller: _pincodeController,
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: _onPincodeChanged,
                  ),
                  SizedBox(height: 14.h),

                  _buildDropdownField(
                    label: 'State',
                    value: _selectedStateLabel,
                    options: _statesList,
                    onChanged: _onStateChanged,
                    isLoading: _isLoadingStates,
                  ),
                  SizedBox(height: 14.h),

                  _buildDropdownField(
                    label: 'District',
                    value: _selectedDistrictLabel,
                    options: _districtsList,
                    onChanged: _onDistrictChanged,
                    isLoading: _isLoadingDistricts,
                  ),
                  SizedBox(height: 14.h),

                  // ── Verification Status Info Box ──
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color:  Color(0xFFF0F7FF), // Soft blue background
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE0E9F5), // Border outline
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blue square shield container
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color:  Color(0xFFDBEAFE), // Light blue box
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF0284C7), // Blue check-shield
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color:  Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Your account is fully KYC verified. Most identity details are locked to ensure account security.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // ── Save Changes Button ──
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AC6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:  Color(0xFF82A3E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name.', style: GoogleFonts.poppins(fontSize: 13.sp)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email.', style: GoogleFonts.poppins(fontSize: 13.sp)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    if (_emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix email validation errors.', style: GoogleFonts.poppins(fontSize: 13.sp)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    final cleanMobile = _phoneController.text.replaceAll(' ', '');
    if (cleanMobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number must be exactly 10 digits.', style: GoogleFonts.poppins(fontSize: 13.sp)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final response = await ProfileApiService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: cleanMobile,
      address: _addressController.text.trim(),
      pincode: _pincodeController.text.trim(),
      state: _selectedStateValue,
      district: _selectedDistrictValue,
      pickedFile: _pickedFile,
    );

    setState(() {
      _isSaving = false;
    });

    final status = response?['status'];
    if (response != null && (status == 'success' || status == true || status?.toString() == 'true')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Profile updated successfully', style: GoogleFonts.poppins(fontSize: 13.sp)),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to update profile. Please try again.', style: GoogleFonts.poppins(fontSize: 13.sp)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color:  Color(0xFF42474E),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color:  Color(0xFFF1F3F9), // Light grey background
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF191C20),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 16.w, top: 14.h, bottom: 14.h),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  icon,
                  color:  Color(0x6642474E), // Suffix icon (40% opacity)
                  size: 25.w,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 25,
                minWidth: 25,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> options,
    required ValueChanged<Map<String, dynamic>> onChanged,
    bool isLoading = false,
  }) {
    String? selectedValue;
    if (value != null) {
      final match = options.firstWhere(
        (opt) => opt['label'].toString().toLowerCase() == value.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty) {
        selectedValue = match['value']?.toString();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF42474E),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F9),
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004AC6)),
                    ),
                  ],
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    hint: Text(
                      'Select $label',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0x6642474E),
                      size: 25.w,
                    ),
                    dropdownColor: Colors.white,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF191C20),
                    ),
                    items: options.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['value']?.toString(),
                        child: Text(opt['label']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final chosen = options.firstWhere((opt) => opt['value']?.toString() == val);
                        onChanged(chosen);
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class FiveDigitSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = text.substring(0, text.length > 10 ? 10 : text.length);
    
    String formatted = '';
    if (digits.length > 5) {
      formatted = '${digits.substring(0, 5)} ${digits.substring(5)}';
    } else {
      formatted = digits;
    }
    
    int digitCountBeforeSelection = 0;
    
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitCountBeforeSelection++;
      }
    }
    
    if (digitCountBeforeSelection > 10) {
      digitCountBeforeSelection = 10;
    }
    
    int newSelectionEnd = digitCountBeforeSelection;
    if (digitCountBeforeSelection > 5) {
      newSelectionEnd += 1;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionEnd),
    );
  }
}

// GENERATED from ApsaraTalent-Web/utils/constants/ui.constant.ts by
// tool/generate_signup_options.py — do not edit by hand. Both apps must offer
// the same values: career scopes and locations are stored and matched as these
// exact strings, so a mobile-only spelling would create a scope no web user can
// ever match.

/// A choice with a human label and the value the API stores.
class SignupOption {
  const SignupOption(this.label, this.value);

  final String label;
  final String value;
}

class SignupOptions {
  const SignupOptions._();

  static const List<String> careerScopes = [
    "Software Engineering",
    "Frontend Development",
    "Backend Development",
    "Mobile App Development",
    "Full Stack Development",
    "UI/UX Design",
    "Game Development",
    "Data Science",
    "Cloud Computing",
    "DevOps Engineering",
    "Cybersecurity",
    "Ethical Hacking & Penetration Testing",
    "Artificial Intelligence & Machine Learning",
    "Machine Learning Engineering",
    "Blockchain Development",
    "Quantum Computing Research",
    "Finance & Accounting",
    "Sales & Business Development",
    "Human Resources (HR)",
    "Project Management",
    "Product Management",
    "Entrepreneurship & Startups",
    "Customer Support & Service",
    "Investment Banking",
    "Insurance & Risk Management",
    "Actuarial Science",
    "Market Research & Consumer Behavior",
    "Digital Marketing",
    "Social Media Management",
    "Graphic Design",
    "Content Writing & Copywriting",
    "Public Relations (PR)",
    "Photography & Videography",
    "Film & Video Production",
    "Journalism & Media",
    "Music Production & Sound Engineering",
    "Fashion Design & Merchandising",
    "Voice Acting & Dubbing",
    "Esports & Gaming Industry",
    "Civil Engineering",
    "Architecture",
    "Interior Design",
    "Real Estate & Property Management",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Renewable Energy Engineering",
    "Automobile Engineering",
    "Robotics Engineering",
    "Aerospace Engineering",
    "E-commerce Management",
    "Logistics & Supply Chain Management",
    "Hospitality & Tourism",
    "Event Planning & Management",
    "Culinary Arts & Food Science",
    "Healthcare & Nursing",
    "Dentistry",
    "Dermatology & Skincare",
    "Mental Health Therapy",
    "Speech Therapy & Audiology",
    "Veterinary Medicine",
    "Geriatric & Elderly Care",
    "Fitness & Personal Training",
    "Sports Management",
    "Pharmaceutical Research",
    "Biotechnology & Biomedical Science",
    "Food Technology & Nutrition Science",
    "Education & Teaching",
    "Law & Legal Consulting",
    "Nonprofit & NGO Management",
    "Political Science & Public Administration",
    "Linguistics & Translation Services",
    "Disaster Management & Humanitarian Aid",
    "Military & Defense Services",
    "Firefighting & Emergency Response",
    "Forensic Science & Criminology",
    "Ethnography & Anthropology",
    "Agricultural Science & Farming",
    "Environmental Science & Sustainability",
    "Forestry & Wildlife Conservation",
    "Marine Biology & Oceanography",
    "Wildlife Photography & Nature Conservation",
    "Legal Tech & Compliance",
    "HR Tech & Talent Acquisition",
    "Cyberlaw & Digital Ethics",
    "AI Ethics & Policy Making",
    "Smart Cities & Urban Planning",
    "Drone Technology & UAV Operations",
    "3D Printing & Additive Manufacturing",
    "Virtual Reality (VR) & Augmented Reality (AR)",
    "Metaverse Development",
    "NFT Development & Crypto Trading",
    "Crowdfunding & Startup Investment",
    "Nanotechnology & Materials Science",
    "Bioinformatics & Computational Biology",
    "Space Exploration & Satellite Engineering",
    "Space Science & Astronomy",
    "Astrobiology & Space Medicine",
  ];

  static const List<String> locations = [
    "Phnom Penh",
    "Banteay Meanchey",
    "Battambang",
    "Kampong Cham",
    "Kampong Chhnang",
    "Kampong Speu",
    "Kampong Thom",
    "Kampot",
    "Kandal",
    "Kep",
    "Koh Kong",
    "Kratie",
    "Mondulkiri",
    "Oddar Meanchey",
    "Pailin",
    "Preah Sihanouk",
    "Preah Vihear",
    "Prey Veng",
    "Pursat",
    "Ratanakiri",
    "Siem Reap",
    "Stung Treng",
    "Svay Rieng",
    "Takeo",
    "Tbong Khmum",
  ];

  static const List<SignupOption> yearsOfExperience = [
    SignupOption("No Experience", "No Experience"),
    SignupOption("Less than 1 year", "Less than 1 year"),
    SignupOption("1 - 2 years", "1 - 2 years"),
    SignupOption("3 - 5 years", "3 - 5 years"),
    SignupOption("6 - 10 years", "6 - 10 years"),
    SignupOption("10+ years", "10+ years"),
  ];

  static const List<SignupOption> availability = [
    SignupOption("Full Time", "full_time"),
    SignupOption("Part Time", "part_time"),
    SignupOption("Internship", "internship"),
    SignupOption("Contract", "contract"),
    SignupOption("Freelance", "freelance"),
  ];

  /// Suggestions only — the API stores company type as free text.
  static const List<SignupOption> companyTypes = [
    SignupOption("Startup", "startup"),
    SignupOption("SME", "sme"),
    SignupOption("Enterprise", "enterprise"),
    SignupOption("NGO", "ngo"),
    SignupOption("Government", "government"),
  ];

  static const List<SignupOption> genders = [
    SignupOption("Male", "male"),
    SignupOption("Female", "female"),
    SignupOption("Prefer not to say", "other"),
  ];

  /// The API rejects a founding year before this (`FOUNDED_YEAR_MIN` on web).
  static const int foundedYearMin = 1900;
}

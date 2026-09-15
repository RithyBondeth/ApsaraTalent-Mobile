#!/usr/bin/env python3
"""Regenerate lib/features/auth/domain/constants/signup_options.dart.

Reads the web app's signup constants so both apps offer identical values.
Run from ApsaraTalent-Mobile with the web repo checked out beside it:

    python3 tool/generate_signup_options.py
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
WEB = ROOT.parent / 'ApsaraTalent-Web' / 'utils' / 'constants' / 'ui.constant.ts'
OUT = ROOT / 'lib' / 'features' / 'auth' / 'domain' / 'constants' / 'signup_options.dart'

if not WEB.exists():
    sys.exit(f'Web constants not found at {WEB}')
src = WEB.read_text()


def block(name):
    start = src.index(f'export const {name}')
    return src[start:src.index('] as const;', start)]


def str_list(name):
    return re.findall(r'^\s*"([^"]+)",\s*$', block(name), re.M)


def pairs(name):
    return re.findall(r'label:\s*"([^"]+)",\s*value:\s*"([^"]+)"', block(name))


scopes = re.findall(r'value:\s*"([^"]+)"', block('careerScopesListConstant'))
locations = str_list('locationConstant')
if not scopes or not locations:
    sys.exit('Parsed an empty list — has the web constant file changed shape?')


def dstr(s):
    return json.dumps(s, ensure_ascii=False).replace('$', r'\$')


def dlist(items):
    return '\n'.join(f'    {dstr(x)},' for x in items)


def dpairs(items):
    return '\n'.join(f'    SignupOption({dstr(l)}, {dstr(v)}),' for l, v in items)


OUT.write_text(f'''// GENERATED from ApsaraTalent-Web/utils/constants/ui.constant.ts by
// tool/generate_signup_options.py — do not edit by hand. Both apps must offer
// the same values: career scopes and locations are stored and matched as these
// exact strings, so a mobile-only spelling would create a scope no web user can
// ever match.

/// A choice with a human label and the value the API stores.
class SignupOption {{
  const SignupOption(this.label, this.value);

  final String label;
  final String value;
}}

class SignupOptions {{
  const SignupOptions._();

  static const List<String> careerScopes = [
{dlist(scopes)}
  ];

  static const List<String> locations = [
{dlist(locations)}
  ];

  static const List<SignupOption> yearsOfExperience = [
{dpairs(pairs('yearOfExperienceConstant'))}
  ];

  static const List<SignupOption> availability = [
{dpairs(pairs('availabilityConstant'))}
  ];

  /// Suggestions only — the API stores company type as free text.
  static const List<SignupOption> companyTypes = [
{dpairs(pairs('companyTypeConstant'))}
  ];

  static const List<SignupOption> genders = [
{dpairs(pairs('genderConstant'))}
    SignupOption("Prefer not to say", "other"),
  ];

  /// The API rejects a founding year before this (`FOUNDED_YEAR_MIN` on web).
  static const int foundedYearMin = 1900;
}}
''')
print(f'wrote {OUT.relative_to(ROOT)}: {len(scopes)} career scopes, {len(locations)} locations')

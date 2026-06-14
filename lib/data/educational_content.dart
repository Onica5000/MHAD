/// Educational content sourced directly from the PA MHAD booklet
/// (Act 194 of 2004, published by the Disabilities Law Project).
library;

enum EducationCategory {
  intro,
  faq,
  combined,
  declaration,
  poa,
  glossary,
  supplementary,
  checklist;

  String get displayName {
    switch (this) {
      case intro:
        return 'Introduction';
      case faq:
        return 'FAQ';
      case combined:
        return 'Combined Form';
      case declaration:
        return 'Declaration';
      case poa:
        return 'Power of Attorney';
      case glossary:
        return 'Glossary';
      case supplementary:
        return 'Beyond the Booklet';
      case checklist:
        return 'Your Checklist';
    }
  }
}

class EducationSection {
  final String id;
  final EducationCategory category;
  final String title;
  final String content;

  const EducationSection({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
  });
}

// ---------------------------------------------------------------------------
// INTRODUCTION
// ---------------------------------------------------------------------------

const _introduction = [
  EducationSection(
    id: 'intro_overview',
    category: EducationCategory.intro,
    title: 'What is the PA Mental Health Advance Directive?',
    content:
        'On November 3, 2004, Governor Rendell signed House Bill 2036 into law '
        'making it Act 194 of 2004. By allowing you to create a Mental Health '
        'Advance Directive — which can include a Declaration and/or a Mental '
        'Health Power of Attorney — this new law promotes planning ahead for '
        'the mental health services and supports that you might want to receive '
        'during a crisis if you are unable to make decisions.\n\n'
        'Act 194 became effective on January 29, 2005. A Mental Health Care '
        'Advance Directive is a tool that focuses on wellness and recovery '
        'planning. Pennsylvania is pleased to join the national trend of '
        'promoting the use of this tool as a mental health policy.\n\n'
        'It is important to understand how to make this new law work for you — '
        'including how to create an Advance Directive and/or appoint an agent '
        'for your mental health Power of Attorney.\n\n'
        'This app includes forms and instructions that you can use to create '
        'your advance directive and answers to frequently asked questions.',
  ),
  EducationSection(
    id: 'intro_why_take_your_time',
    category: EducationCategory.intro,
    title: 'Why taking your time pays off',
    content:
        'Research on psychiatric advance directives consistently finds that '
        'people who complete one through a deliberate, guided process — with '
        'time to think through their crisis history, their preferences, and '
        'who they trust to speak for them — are far more likely to have a '
        'directive that is actually used and honored. In one randomised '
        'study, that kind of guided completion reduced the use of coercive '
        'interventions (like involuntary hospitalisation) by roughly half '
        'over the next two years.\n\n'
        'This app is built around the same idea. The wizard walks you through '
        'the questions a trained facilitator would ask, the AI assistant is '
        'there for clarifying explanations (not advice), and the education '
        'section is open at any step. There is no rush — saving and coming '
        'back is fine, and revising your directive later is fine too.\n\n'
        'The most common reason a directive fails is not the document itself '
        'but that the people treating you cannot find it during a crisis. '
        'When you finish, the app will show you a checklist for making your '
        'directive findable: carry the wallet card, share copies with your '
        'agent and providers, and tell the people around you that it exists.',
  ),
  EducationSection(
    id: 'intro_contacts',
    category: EducationCategory.intro,
    title: 'Where to Get Help',
    content:
        'If you have additional questions or need assistance with completing a '
        'form, contact any one of the following organizations:\n\n'
        '• Pennsylvania Mental Health Consumers\' Association\n'
        '  1-800-88PMHCA\n'
        '  pmhca@pmhca.org\n\n'
        '• Pennsylvania Protection & Advocacy / Disabilities Law Project\n'
        '  1-800-692-7443\n'
        '  717-236-8110\n'
        '  1-877-375-7139 (TDD/TTY)\n\n'
        '• Mental Health Association in Pennsylvania\n'
        '  1-866-578-3659\n'
        '  717-346-0549\n'
        '  info@mhapa.org',
  ),
];

// ---------------------------------------------------------------------------
// FREQUENTLY ASKED QUESTIONS
// ---------------------------------------------------------------------------

const _faq = [
  EducationSection(
    id: 'faq_what_is',
    category: EducationCategory.faq,
    title: 'What is a Mental Health Advance Directive?',
    content:
        '**In simple terms: It\'s a written plan for your mental health care '
        'if you can\'t speak for yourself.**\n\n'
        'A Mental Health Advance Directive is a document that allows you to '
        'make your choices known regarding mental health treatment in the event '
        'that your mental illness makes you unable to make decisions. In effect, '
        'you are making decisions about treatment before the time that you will '
        'need it. This allows you to make more informed decisions and to make '
        'your wishes clearly known. A new law was passed in Pennsylvania, '
        'effective January 28, 2005, that makes it possible for you to use a '
        'Mental Health Advance Directive.\n\n'
        'Many decisions may need to be made for you if you have a mental health '
        'crisis or are involuntarily committed and become unable to make '
        'treatment decisions. For example, the choice of hospital, types of '
        'treatment, and who should be notified are decisions that may be made '
        'for you. One way to be sure that your doctor, relatives, and friends '
        'understand your feelings is to prepare a Mental Health Advance '
        'Directive before you become unable to make decisions.\n\n'
        'Pennsylvania law allows you to make a Mental Health Advance Directive '
        'that is a declaration, a power of attorney, or a combination of both.',
  ),
  EducationSection(
    id: 'faq_combined',
    category: EducationCategory.faq,
    title: 'What are the three types — Combined, Declaration, and Power of '
        'Attorney?',
    content:
        'Pennsylvania law lets you make a Mental Health Advance Directive as a '
        '**Declaration**, a **Power of Attorney**, or a **combination of '
        'both**. You pick whichever fits how much you want to decide in '
        'advance versus how much you want a trusted person to decide for '
        'you.\n\n'
        '**Declaration** — *a written list of instructions to your care '
        'team.* A Declaration contains instructions to doctors, hospitals, and '
        'other mental health care providers about your treatment in the event '
        'that you become unable to communicate your wishes. It usually deals '
        'with specific situations and does not allow much flexibility for '
        'changes that come up after the document is written, such as a new type '
        'of crisis, new kinds of medication, or different treatment '
        'choices.\n\n'
        '**Power of Attorney** — *you choose a trusted person to decide for '
        'you.* A Mental Health Power of Attorney lets you designate someone '
        'else, called an agent, to make treatment decisions for you during a '
        'mental health crisis. It provides flexibility to deal with a situation '
        'as it occurs rather than trying to anticipate every possible '
        'situation in advance.\n\n'
        '**Combined Declaration and Power of Attorney** — *write your wishes '
        'AND pick someone to decide.* A combined directive lets you make some '
        'decisions yourself while giving an agent power to make others — as '
        'many or as few as you like. This makes your directive more flexible '
        'for future situations, such as new treatment options, that you have '
        'no way of knowing about now.\n\n'
        'Whichever you choose, your agent should be someone you trust, and you '
        'should discuss your feelings about different treatment choices with '
        'them so they can make decisions most like the ones you would make '
        'yourself.',
  ),
  EducationSection(
    id: 'faq_valid',
    category: EducationCategory.faq,
    title: 'What makes a Mental Health Care Advance Directive valid?',
    content:
        '**In simple terms: You must be 18 or older (or an emancipated minor), '
        'sign it, and have two adult witnesses.**\n\n'
        'There is no specific form that must be used, but your Mental Health '
        'Advance Directive must meet the following requirements:\n\n'
        '1. You must be at least 18 years of age, or an emancipated minor.\n\n'
        '2. You must not have been declared incapacitated by a court and had a '
        'guardian appointed, or currently be under an involuntary commitment.\n\n'
        '3. The Mental Health Advance Directive must be signed, witnessed, and '
        'dated. Witnesses must be at least 18 years old. If you cannot '
        'physically sign the document, another person may sign for you, but '
        'the person signing may not also be a witness. Your doctor or his/her '
        'employee, or an owner, operator, or employee of a residential facility '
        'where you are living cannot serve as an agent.\n\n'
        '4. The Mental Health Advance Directive must contain your choices about '
        'beginning, continuing, or refusing mental health treatment. It also '
        'can include choices about other things, such as who you want to be '
        'your agent or guardian, who you want to care for your children or '
        'pets, who you want notified about your condition, and/or your dietary '
        'or religious choices.\n\n'
        '5. If your Mental Health Advance Directive is a Power of Attorney, '
        'then you must name the person you want to be your agent and say that '
        'you are authorizing them to make whatever decisions you want them to '
        'make.\n\n'
        'The Mental Health Advance Directive is valid for two years from the '
        'date you sign it unless: (a) you revoke the entire directive, or '
        '(b) you make a new Mental Health Advance Directive.\n\n'
        'If you do not have capacity to make treatment decisions at the time '
        'the directive will end, the Advance Directive will stay in place until '
        'you are able to make treatment decisions.',
  ),
  EducationSection(
    id: 'faq_capacity',
    category: EducationCategory.faq,
    title: 'What is capacity, and do I need to prove it?',
    content:
        'Capacity is the basic ability to understand your diagnosis and to '
        'understand the risks, benefits, and alternative treatments of your '
        'mental health care. It also includes the ability to understand what '
        'may happen if you do not receive treatment.\n\n'
        '**Do I need to include proof of my capacity?** No. Unless you have a '
        'guardian or are currently under an involuntary commitment, you are '
        'presumed to have capacity when you make a Mental Health Advance '
        'Directive. However, at a later time it is possible for someone to '
        'challenge whether you had capacity.\n\n'
        'If you want to be very sure that no one can challenge your directive '
        'later, you can include a letter from your treating doctor, from the '
        'same time period that you made your directive, stating that you had '
        'capacity at that time.',
  ),
  EducationSection(
    id: 'faq_effective',
    category: EducationCategory.faq,
    title: 'When does my directive take effect, and who decides I lack '
        'capacity?',
    content:
        '**When it takes effect.** You can write in your Mental Health Advance '
        'Directive when you want the directive to take effect — for example, '
        'when involuntary commitment occurs, or when a psychiatrist and '
        'another mental health treatment professional state that you no longer '
        'have capacity to make mental health treatment decisions.\n\n'
        '**Who determines incapacity.** For the purpose of your directive, '
        'incapacity is determined after you are examined by a psychiatrist and '
        'one of the following: another psychiatrist, psychologist, family '
        'physician, attending physician, or mental health treatment '
        'professional. Whenever possible, one of the decision makers will be '
        'one of your current treating professionals.\n\n'
        '**If the evaluators disagree.** If the two professionals disagree '
        'about whether you lack capacity, the directive does NOT become '
        'operative — you are presumed to have capacity unless both evaluators '
        'agree. You or your agent may request additional evaluations if you '
        'believe the determination is incorrect.',
  ),
  EducationSection(
    id: 'faq_guardian',
    category: EducationCategory.faq,
    title: 'What if a court appoints a guardian after I have appointed an agent?',
    content:
        'In your Advance Directive you can name someone you want the court to '
        'choose as your guardian. The court will appoint the person you choose, '
        'unless there is a good reason not to. In many cases your agent and the '
        'person you would want to be your guardian would be the same person. '
        'However, you may want one person to make your mental health care '
        'decisions, and someone else to make other decisions for you.\n\n'
        'If the court-appointed guardian and your agent are different people, '
        'the court will allow your agent to make mental health care decisions, '
        'unless you say otherwise in your Mental Health Advance Directive. If '
        'the court decides to grant the powers that you gave to an agent to the '
        'guardian, the guardian would still have to make decisions as written '
        'in your Advance Directive.\n\n'
        '**You decide whether a guardian can override your directive.** If a '
        'court later appoints a guardian for you (under 20 Pa.C.S. §5511), '
        'your directive lets you choose one of two options:\n\n'
        '• The guardian CANNOT revoke, suspend, or terminate your directive — '
        'your pre-stated wishes remain in effect.\n'
        '• The guardian CAN revoke, suspend, or terminate your directive — '
        'giving the guardian full authority.\n\n'
        'This is an important decision. If you have strong feelings about your '
        'treatment preferences, consider preventing the guardian from '
        'overriding them. If you trust that a future guardian would act in '
        'your best interest, you may allow revocation.\n\n'
        'Remember that your agent and your guardian are different roles: your '
        'agent makes decisions under the power of attorney, while a guardian '
        'has broader court-granted authority over your personal affairs.',
  ),
  EducationSection(
    id: 'faq_providers_follow',
    category: EducationCategory.faq,
    title: 'Do health care providers have to follow my instructions?',
    content:
        '**Short answer: yes — and the law uses mandatory language.**\n\n'
        'Under PA Act 194, **20 Pa.C.S. §5842** (Duties of Attending '
        'Physician and Mental Health Care Provider) requires that an '
        'attending physician or mental health care provider "**shall '
        'comply** with a mental health care decision made by a mental '
        'health care agent." In statutory drafting, "shall" creates a '
        'duty — this is not a suggestion. The agent\'s decision is '
        'treated as if you had made it yourself.\n\n'
        'The same mandatory framework applies to your general health-care '
        'agent under the parallel statute, **20 Pa.C.S. §5462(c)(1)** of '
        'Chapter 54 (Act 169 of 2006), which says that outside a narrow '
        'life-preserving carve-out, the provider "**shall comply** with a '
        'health care decision made by a health care agent or health care '
        'representative to the same extent as if the decision had been '
        'made by the principal."\n\n'
        '**Narrow exceptions.** A provider may decline to comply when:\n'
        '• Your instructions are against accepted clinical practice and '
        'medical standards; or\n'
        '• The treatment is physically unavailable at the facility; or\n'
        '• Provider/institutional policy or insurance coverage precludes '
        'compliance (see the Supplementary section "Insurance, coverage, and '
        'provider-policy limits"); or\n'
        '• The provider has a good-faith conscience objection; or\n'
        '• The directive is not legally effective — for example, it was not '
        'properly executed, has expired (past the two-year period while you '
        'still have capacity), was revoked, or has not yet been activated '
        'under the trigger you specified (such as involuntary commitment or a '
        'capacity determination by a psychiatrist and another professional).\n\n'
        'When a provider cannot comply, **§5804** requires them to (a) '
        'tell you, your agent, and any guardian as soon as possible, '
        '(b) document the reason, (c) make a reasonable effort to '
        'transfer your care to a provider who will comply, and (d) '
        'continue providing care under your directive while the transfer '
        'is pending.\n\n'
        '**Beware of "guidelines only" framing.** Some hospital handouts '
        'and patient FAQs describe advance directives as "guidelines '
        'only" or say there is "no law that guarantees" compliance. '
        'That language understates the statutory rule. The rule is '
        'mandatory compliance plus a defined set of exceptions and a '
        'duty to transfer — not pure clinical discretion. See the '
        'Supplementary section "Provider Obligations Under Act 194" and '
        'the FAQ "What if a provider says my directive is just a '
        'guideline?" for the full statutory analysis.\n\n'
        '**Practical advice.** Discuss your directive with your providers '
        'in advance so you know whether they will be able to follow it. '
        'Even when you consent in advance to a specific medication or '
        'treatment, the clinical decision to use it at any given time '
        'still must be appropriate to your condition at that moment and '
        'within accepted standards of care.\n\n'
        '**If you believe your directive is being ignored:** a provider '
        'cannot decline simply because they personally disagree with your '
        'choice. If transfer to a complying provider is not possible, the '
        'provider must continue to act in your best interest while consulting '
        'your agent. Contact Disability Rights Pennsylvania (formerly PA '
        'Protection & Advocacy) at 1-800-692-7443 — they handle Act 194 '
        'complaints. A court can also set aside specific provisions of a '
        'directive, but only through the §5843 petition process (see the '
        'Supplementary section "Court Petition for Irreparable Harm").',
  ),
  EducationSection(
    id: 'faq_involuntary',
    category: EducationCategory.faq,
    title: 'How does my directive interact with involuntary commitment '
        '(sections 302–305)?',
    content:
        'Having a Mental Health Advance Directive does not change '
        'Pennsylvania\'s voluntary and involuntary commitment provisions under '
        'the Mental Health Procedures Act. What it can affect is how you are '
        'treated *after* you are committed.\n\n'
        'The commitment sections (50 P.S. §§ 7301–7306) are distinct from Act '
        '194 but often come up together, because a directive may take effect '
        'during an involuntary admission:\n\n'
        '• **Section 302** — Emergency examination and treatment for up to '
        '**120 hours** (5 days). Initiated by a physician, peace officer, or '
        'any responsible adult through a written petition.\n'
        '• **Section 303** — Extended emergency involuntary treatment for up '
        'to **20 days** following a 302. Requires a court hearing within 120 '
        'hours of the initial 302 admission.\n'
        '• **Section 304** — Court-ordered involuntary treatment for up to '
        '**90 days** (renewable for additional 90-day periods). Requires a '
        'formal certification and an additional hearing.\n'
        '• **Section 305** — A further 180-day extension after a 304.\n\n'
        'Your MHAD continues to apply during a 302/303/304 admission to the '
        'extent permitted by law. Your agent (if you have one) retains '
        'authority over the decisions the agent has been given, and your '
        'preferences should still inform the care team. The commitment '
        'procedure itself, however, is governed by the Mental Health '
        'Procedures Act, not by Act 194.\n\n'
        'Being committed does not by itself let staff ignore your directive. '
        'During a genuine safety emergency they may give necessary treatment '
        'over your objection while the emergency lasts; outside an emergency '
        'your directive still governs, and a medication refusal in it is '
        'treated as a contemporaneous objection that must be honored while '
        'valid (see the Supplementary section "Emergency Override & Section '
        '302").',
  ),
  EducationSection(
    id: 'faq_revoke',
    category: EducationCategory.faq,
    title: 'Can I change or revoke my directive?',
    content:
        '**You may revoke, or cancel, a part or the whole of your Mental '
        'Health Advance Directive at any time, as long as you have capacity** '
        'to make mental health care decisions. A revocation can be oral or in '
        'writing, and it is effective as soon as you communicate it to your '
        'attending physician or mental health care provider — either directly '
        'or through a witness to your revocation.\n\n'
        '**Three ways to revoke:**\n\n'
        '1. **In writing** — sign and date a statement saying you are revoking '
        'the directive.\n'
        '2. **By destroying the original** — physically tear up, shred, or '
        'otherwise destroy the original document with the intent to revoke.\n'
        '3. **By executing a new directive** — signing a new Mental Health '
        'Advance Directive automatically revokes any prior one.\n\n'
        '**Make the revocation stick — notify everyone who has a copy.** '
        'Notification matters as much as the act itself: a directive whose '
        'revocation you forgot to communicate may still be used in good faith '
        'by a provider who has an old copy. A complete revocation usually '
        'means:\n\n'
        '1. Notify your agent(s) in writing.\n'
        '2. Notify your healthcare providers (psychiatrist, therapist, primary '
        'care doctor).\n'
        '3. Notify any hospital or facility that has a copy.\n'
        '4. Destroy or clearly mark "REVOKED" on all printed copies.\n'
        '5. Request the return of copies you distributed.\n\n'
        '**You can also revoke only part of your directive** while keeping the '
        'rest in effect — for example, revoke the agent designation but keep '
        'your treatment preferences.\n\n'
        '**Changing it instead of revoking.** You may change your directive in '
        'writing at any time, as long as you have capacity. For significant '
        'changes it is best to make a new document so there are no conflicts '
        'or misunderstandings. Any change or new directive must be witnessed '
        'by two individuals at least 18 years old, and you should give new '
        'copies to your provider, agent, and other support people.\n\n'
        '**If you do not revoke it,** your Advance Directive automatically ends '
        'two years from the date you signed it — unless you do not have '
        'capacity to make mental health care decisions at that time, in which '
        'case it stays in force until you regain capacity.',
  ),
  EducationSection(
    id: 'faq_what_to_include',
    category: EducationCategory.faq,
    title: 'What types of instructions should I include?',
    content:
        'A Mental Health Advance Directive is a way to communicate lots of '
        'information to your provider. You may wish to include your choices '
        'about different treatment options, such as medications, electro-shock '
        'therapy, and crisis management. In addition, you may say who you want '
        'to be told in the event of a crisis, or write down your dietary '
        'choices, past treatment history, who you want to take care of your '
        'children or pets, and other information that you want to be taken '
        'care of while you seek treatment.',
  ),
  EducationSection(
    id: 'faq_who_to_give',
    category: EducationCategory.faq,
    title: 'Who should get a copy, and how do providers access it?',
    content:
        'The only way your providers will know your choices is if you give '
        'them your Mental Health Advance Directive — PA law does not create a '
        'central registry, so access depends on you and your agent sharing '
        'copies.\n\n'
        'Give copies to your treating physician, psychiatrist and other mental '
        'health providers, your agent, and family members or other people who '
        'would be notified in the event of a crisis. Consider giving a copy to '
        'your local emergency room or crisis center too. Keep the original in '
        'a safe place, and be sure that someone who would be told of any '
        'crisis can get the original so it can be given to the attending '
        'physician.\n\n'
        'Make it findable in an emergency:\n'
        '• Carry a wallet card stating that you have a Mental Health Advance '
        'Directive and who to call if you lack capacity — include that '
        'person\'s phone numbers, and name a backup in case the first person '
        'is unavailable (this app can generate the card).\n'
        '• Tell your agent where the original is stored.\n'
        '• Keep a digital copy on your phone for emergencies.\n'
        '• Some hospitals and health systems let you upload advance directives '
        'to your patient portal or electronic health record.\n\n'
        'Remember that if you make changes or create a new directive, you must '
        'be sure everyone has copies of the most recent version.',
  ),
  EducationSection(
    id: 'faq_out_of_state',
    category: EducationCategory.faq,
    title: 'Will my PA directive be recognized if I travel or move to '
        'another state?',
    content:
        'Pennsylvania law (20 Pa.C.S. §5845) provides that a mental health '
        'advance directive executed in another state is valid in PA if it was '
        'valid where it was executed. The reverse, however, is not '
        'guaranteed: other states are not required to honor a Pennsylvania '
        'directive the way PA providers are, though many extend "reasonable '
        'recognition" to out-of-state directives as a matter of clinical '
        'practice.\n\n'
        'If you travel or move between states:\n\n'
        '• Bring a copy of your PA directive AND a brief cover sheet '
        'identifying it as a "mental health advance directive under '
        'Pennsylvania Act 194 of 2004 (20 Pa.C.S. Ch. 58)."\n'
        '• Carry the wallet card and the names and phone numbers of your PA '
        'agent.\n'
        '• If you settle in another state, consider executing a new directive '
        'under that state\'s law in addition to your PA one.\n'
        '• Check the other state\'s laws or consult an attorney about '
        'cross-border recognition.\n\n'
        'For specific cross-border questions, contact PA Protection & '
        'Advocacy (1-800-692-7443).',
  ),
  EducationSection(
    id: 'faq_agent_unavailable',
    category: EducationCategory.faq,
    title: 'What if my agent is unavailable or disagrees with my wishes?',
    content:
        '**If your agent is unavailable.** If your primary agent cannot be '
        'reached or is unable to serve, your alternate agent (if you '
        'designated one) will step in. This is why naming an alternate agent '
        'is strongly recommended.\n\n'
        'If neither agent is available, your directive\'s written treatment '
        'preferences still guide your care team. Providers must follow your '
        'documented wishes to the extent possible, even without an agent '
        'present to interpret them. If no agent is available and your '
        'directive does not address the specific treatment decision, providers '
        'will use their clinical judgment consistent with accepted medical '
        'practice.\n\n'
        '**If your agent disagrees with what you wrote.** Your agent is '
        'legally required to act on your stated wishes when your directive is '
        'in effect; their personal disagreement does not authorize them to '
        'override your written instructions. The best safeguard is to have the '
        'conversation now, before any crisis: walk through your directive with '
        'your agent in person — explain why you chose each preference, what '
        'experiences led you to it, and what "honoring" the directive means in '
        'concrete situations (medications, ECT, facilities). An agent who has '
        'had this conversation is far more likely to follow your wishes '
        'confidently and advocate for you with providers. If your agent '
        'indicates they cannot or will not follow your directive, name a '
        'different agent (or move them to the alternate slot and choose a new '
        'primary).',
  ),
  EducationSection(
    id: 'faq_finding_witnesses',
    category: EducationCategory.faq,
    title: 'How do I find eligible witnesses?',
    content:
        'You need two adult witnesses (18+) who are NOT:\n\n'
        '\u2022 Your designated agent or alternate agent\n'
        '\u2022 Your healthcare provider\n'
        '\u2022 An employee of the facility where you receive treatment\n\n'
        'Exception: A person who would otherwise be disqualified MAY serve '
        'as a witness if they are related to you by blood, marriage, or '
        'adoption.\n\n'
        'Good options for witnesses include: friends, neighbors, coworkers, '
        'faith community members, or staff at a library, bank, or community '
        'center. You can also ask an attorney or notary public.\n\n'
        'Both witnesses must be physically present when you sign the '
        'directive. Remote or video witnessing is not accepted under PA law.',
  ),
  EducationSection(
    id: 'faq_deescalation',
    category: EducationCategory.faq,
    title: 'What are de-escalation preferences?',
    content:
        'De-escalation preferences describe what helps you calm down during '
        'a mental health crisis. Documenting these gives your care team '
        'specific tools to help you without resorting to restraint or '
        'forced medication.\n\n'
        'Examples of de-escalation techniques to include:\n\n'
        '\u2022 Listening to music (specify genre or playlist)\n'
        '\u2022 Being in a quiet, dimly lit room\n'
        '\u2022 Talking with a specific person (name and contact)\n'
        '\u2022 Deep breathing or grounding exercises\n'
        '\u2022 Access to comfort items (blanket, stuffed animal, book)\n'
        '\u2022 Being spoken to in a calm, slow voice\n'
        '\u2022 Being left alone for a set period\n'
        '\u2022 Physical activity (walking, stretching)\n\n'
        'Also consider listing triggers that make things worse — loud '
        'environments, specific topics, physical contact, being alone, '
        'or certain people or settings.',
  ),
  EducationSection(
    id: 'faq_reproductive_health',
    category: EducationCategory.faq,
    title: 'Can I include reproductive health preferences?',
    content:
        'Yes. If you are or may become pregnant, you can include '
        'preferences about how your mental health treatment should be '
        'managed during pregnancy, labor, delivery, and postpartum care.\n\n'
        'This is especially important because some psychiatric medications '
        'carry risks during pregnancy, and treatment decisions may need to '
        'balance mental health needs with fetal safety.\n\n'
        'Examples of reproductive health preferences:\n\n'
        '\u2022 Which medications to continue or discontinue during pregnancy\n'
        '\u2022 Whether you consent to psychiatric hospitalization while pregnant\n'
        '\u2022 Preferences for postpartum mental health monitoring\n'
        '\u2022 Who should be notified if you are hospitalized while pregnant\n'
        '\u2022 Preferences for breastfeeding vs. medication compatibility\n\n'
        'Include these in the "Other matters of importance" section of your '
        'directive. California has pioneered a specialized "Reproductive PAD" '
        'template that addresses these issues in detail.',
  ),
  EducationSection(
    id: 'faq_capacity_restoration',
    category: EducationCategory.faq,
    title: 'What happens when I regain capacity?',
    content:
        'Your directive automatically suspends when you regain capacity. '
        'In other words: when you are able to make and communicate your own '
        'mental-health treatment decisions, those current decisions take '
        'precedence over any preference written in your directive.\n\n'
        'When capacity is restored, you can also choose to:\n\n'
        '• **Revoke** the directive (see the revocation FAQ).\n'
        '• **Amend** it by executing a new directive that supersedes the '
        'prior one.\n'
        '• **Leave it alone** so it is ready the next time it is needed.\n\n'
        'Capacity determinations are made by qualified clinicians under PA '
        'Act 194 — typically a physician, certified registered nurse '
        'practitioner, or psychologist familiar with the patient. The '
        'determination must be documented in the medical record.',
  ),
  EducationSection(
    id: 'faq_emancipated_minor',
    category: EducationCategory.faq,
    title: 'Can a minor create a Mental Health Advance Directive?',
    content:
        'Under Pennsylvania law, the principal of an MHAD must be **18 or '
        'older** or a **legally emancipated minor**. Emancipation in PA is '
        'granted by a court and gives a minor adult-like legal capacity for '
        'decisions including healthcare.\n\n'
        'If you are under 18 and not emancipated, you cannot independently '
        'create a binding MHAD, but you can:\n\n'
        '• Talk with a parent or guardian about the kind of treatment you '
        'would want or want to avoid — they make these decisions for you '
        'until you turn 18.\n'
        '• Create a personal "mental-health crisis plan" that lists your '
        'preferences, triggers, supports, and contacts. It is not a binding '
        'directive but it gives clinicians useful information.\n'
        '• Plan to execute an MHAD on or shortly after your 18th birthday.',
  ),
  EducationSection(
    id: 'faq_guidelines_only_misconception',
    category: EducationCategory.faq,
    title:
        'What if a provider says my directive is "just a guideline"?',
    content:
        'This is a common misunderstanding — sometimes repeated by '
        'hospital handouts and patient FAQs. The statute is stronger than '
        'that. Under **20 Pa.C.S. §5842** (for MHADs) and **§5462(c)(1)** '
        '(for general health-care directives), providers "**shall comply**" '
        'with decisions made by a valid agent or representative, treating '
        'them as if you had made them yourself.\n\n'
        'You may see the "guidelines only" framing in widely circulated PA '
        'patient handouts and hospital FAQs — for example, that a directive '
        '"acts only as guidelines, not as automatic medical orders," that '
        'there is "no law in Pennsylvania that guarantees that your medical '
        'providers will follow your instructions in all circumstances," or '
        'language that emphasises "professional judgment" without citing the '
        'statute.\n\n'
        '**Reading that language fairly:** it is not wrong in the absolute '
        'sense — no law literally *guarantees* the outcome in every '
        'conceivable case, and there are narrow statutory exceptions '
        '(conscience, clinical standards, unavailability, institutional '
        'policy, and the life-preserving carve-out in §5462(c)(1) for general '
        'health care). But framing a directive as "guidelines only" buries '
        'the central rule — mandatory compliance — under language emphasising '
        'provider discretion.\n\n'
        '"Shall" is the law\'s word for *required*. It is not "may." It '
        'is not "should consider." It is not a clinical suggestion. The '
        'narrow exceptions (conscience objection, clinical unavailability, '
        'institutional policy) trigger a **transfer obligation**, not a '
        'free-for-all of provider discretion.\n\n'
        '**If a provider tells you "this is just a guideline":**\n\n'
        '1. Stay calm and polite — most staff who say this are repeating '
        'older training, not refusing in bad faith.\n'
        '2. Cite the statute by name: "Under 20 Pa.C.S. §5842, you are '
        'required to comply with my agent\'s decisions to the same '
        'extent as if I had made them." For a non-mental-health '
        'directive, cite §5462(c)(1).\n'
        '3. Ask which of the **specific statutory exceptions** they are '
        'relying on (conscience, clinical standards, unavailability, '
        'institutional policy). Vague clinical disagreement is not one '
        'of the exceptions.\n'
        '4. If they invoke an exception, ask for the **transfer plan** '
        'required by §5804 — who will take the case, and what care will '
        'be provided in the meantime.\n'
        '5. Ask the hospital\'s patient-advocate or ombudsperson to be '
        'involved.\n'
        '6. If the dispute is not resolved, contact **Disability Rights '
        'Pennsylvania (formerly PA Protection & Advocacy)** at '
        '1-800-692-7443. They handle Act 194 complaints.\n\n'
        '**For institutions:** aligning patient handouts and ethics-committee '
        'guidance with the statutory text ("shall comply" + defined exceptions '
        '+ duty to transfer) reduces conflict with surrogates and supports '
        'more consistent practice — the core finding of bioethics commentary '
        'comparing Act 194 and Act 169 with widely used patient materials.\n\n'
        '**Bottom line:** this app describes the provider duty using the '
        'statutory "shall comply" language. If a printed handout or FAQ you '
        'encounter elsewhere describes things differently, the statute is the '
        'controlling authority. See also the FAQ "Do health care providers '
        'have to follow my instructions?" and the Supplementary section '
        '"Provider Obligations Under Act 194" for the full statutory '
        'framework.',
  ),
  EducationSection(
    id: 'faq_mhad_vs_health_care_directive',
    category: EducationCategory.faq,
    title:
        'How is my MHAD different from a regular health-care directive '
        'or living will?',
    content:
        'Pennsylvania has **two parallel advance-directive statutes** in '
        'Title 20 of the Consolidated Statutes. Many people benefit from '
        'having both. They cover different decisions but use the same '
        '"shall comply" framework for provider duties.\n\n'
        '**Chapter 58 — Mental Health Care (Act 194 of 2004).** This is '
        'the law for *mental health* treatment decisions: hospitalization '
        'in a psychiatric facility, psychotropic medications, ECT, '
        'experimental psychiatric studies, drug trials, treatment-facility '
        'preferences, and a mental-health agent. This app generates '
        'directives under Chapter 58.\n\n'
        '**Chapter 54 — Health Care (Act 169 of 2006).** This is the law '
        'for *general* health-care decisions: living wills, end-of-life '
        'care, life-preserving treatment, surgery consent, the general '
        'health-care power of attorney, and the default "health-care '
        'representative" hierarchy when no agent is named.\n\n'
        '**How they fit together:**\n'
        '• If you sign a Chapter 58 MHAD and a Chapter 54 health-care '
        'POA, both can be in force at the same time. The mental-health '
        'agent makes mental-health decisions; the general health-care '
        'agent (or representative) makes everything else.\n'
        '• The same person can be named in both — it often makes sense '
        'for one trusted person to hold both roles.\n'
        '• Both statutes use mandatory "**shall comply**" language for '
        'provider duties (see §5842 for MHAD, §5462(c)(1) for general '
        'health care).\n'
        '• Both allow conscience-based refusal, but both also require '
        'the provider to **transfer** to a complying provider rather '
        'than simply override your wishes.\n\n'
        '**When in doubt, ask which statute applies.** A psychiatric '
        'admission decision is Chapter 58. A do-not-resuscitate question '
        'is Chapter 54. A medication decision during a psychiatric '
        'hospitalization is usually Chapter 58. Hospitals occasionally '
        'cite the wrong statute or apply Chapter 54 rules to a '
        'mental-health situation — knowing the distinction helps you and '
        'your agent advocate correctly.',
  ),
  EducationSection(
    id: 'faq_scenario_admission',
    category: EducationCategory.faq,
    title: 'Sample scenario: how a directive helps during admission',
    content:
        'Here is an anonymised, composite scenario drawn from PAD '
        'implementation literature — it is illustrative, not a real case.\n\n'
        '**Background.** Alex has bipolar I disorder and a history of '
        'manic episodes that have required hospitalisation. Two years ago, '
        'with help from a peer specialist, Alex completed an MHAD that '
        'names his sister as primary agent, declines a specific '
        'antipsychotic that gave him severe akathisia, identifies two '
        'preferred facilities and one to avoid, and consents to ECT only '
        'if his sister also agrees in writing at the time.\n\n'
        '**Crisis.** Alex is brought to a hospital by EMS during a manic '
        'episode. He cannot consistently communicate his preferences.\n\n'
        '**With the directive in place.** The intake nurse finds the '
        'wallet card in Alex\'s pocket, scans the QR code, and pulls up '
        'the directive summary. The team contacts his sister, transfers '
        'him to one of his preferred facilities the next morning, avoids '
        'the named antipsychotic, and starts the medication he listed as '
        'preferred. ECT is not raised because the prerequisite agent-in-'
        'writing condition cannot be met.\n\n'
        '**Why it worked.** The directive existed *and* was findable. The '
        'agent had been briefed in advance. Preferences were specific '
        'enough to guide medication choice, not just record-keeping.',
  ),
];

// ---------------------------------------------------------------------------
// COMBINED FORM INSTRUCTIONS
// ---------------------------------------------------------------------------

const _combined = [
  EducationSection(
    id: 'combined_overview',
    category: EducationCategory.combined,
    title: 'Combined Form Overview',
    content:
        'Pennsylvania\'s law allows you to make a combined Mental Health '
        'Declaration and Power of Attorney. This lets you make decisions about '
        'some things, but also lets you give an agent power to make other '
        'decisions for you. You choose the decisions that you want your agent '
        'to make for you, as many or as few as you like. This makes your '
        'Mental Health Advance Directive more flexible in dealing with future '
        'situations, such as new treatment options, that you would have no way '
        'of knowing about now.\n\n'
        'Read each section very carefully. Begin by printing your name in the '
        'blank in the introductory paragraph at the top of the form.',
  ),
  EducationSection(
    id: 'combined_effective',
    category: EducationCategory.combined,
    title: 'Part I — When the Combined Form Becomes Effective',
    content:
        'Decide when you want the Declaration to become effective. You can '
        'specify a condition, such as if you are involuntarily committed for '
        'either outpatient or inpatient care, or some other behavior or event '
        'that you know happens when you no longer have capacity to make mental '
        'health decisions, or you can specify that you want an evaluation for '
        'incapacity.\n\n'
        'If you do not choose a condition, your incapacity will be determined '
        'after examination by a psychiatrist and one of the following: another '
        'psychiatrist, psychologist, family physician, attending physician, or '
        'other mental health treatment professional. If you have doctors that '
        'you would prefer to make the evaluation, you should specify them in '
        'your Declaration. Although that doctor may not be available, an effort '
        'will at least be made to contact them.\n\n'
        'Until your condition is met, or you are found to be unable to make '
        'mental health decisions, you will make decisions for yourself.',
  ),
  EducationSection(
    id: 'combined_revocation',
    category: EducationCategory.combined,
    title: 'Part I — Revocations and Amendments',
    content:
        'Revocation means that you are canceling your Directive. If you revoke '
        'your Directive, your doctor will no longer have to follow the '
        'instructions that you gave in the document. You may change or revoke '
        'your Directive at any time, as long as you have capacity to make '
        'mental health decisions when you make the change or revocation. You '
        'may revoke a specific instruction without revoking the entire '
        'document.\n\n'
        'If you are currently under an involuntary commitment and you want to '
        'change or revoke your Declaration, you will need to request an '
        'evaluation to determine if you are capable of making mental health '
        'decisions. The evaluation will be done by a psychiatrist and another '
        'psychiatrist, psychologist, family physician, attending physician or '
        'other mental health professional.\n\n'
        'You may revoke your Mental Health Advance Directive orally or in '
        'writing. Your Advance Directive will terminate as soon as you '
        'communicate your revocation to your treating doctor. It is best to '
        'make any changes or revocation in writing, because then there is a '
        'clear record of your wishes.\n\n'
        'To amend your Directive means that you make changes to it. You may '
        'make changes at any time, as long as you have capacity to make mental '
        'health care decisions. Any changes must be made in writing and be '
        'signed and witnessed by two individuals in the same way as the '
        'original document. Any changes will be effective as soon as the '
        'changes are communicated to your attending physician or other mental '
        'health care provider.',
  ),
  EducationSection(
    id: 'combined_facility',
    category: EducationCategory.combined,
    title: 'Part II — Choice of Treatment Facility',
    content:
        'If you have a preference for, or bad feelings toward, any particular '
        'hospital, list them here. Unfortunately, there are times when a '
        'particular place is already full and would be unable to accommodate '
        'you, or the treating doctor does not have privileges at the hospital '
        'you would prefer. Therefore, although your doctor will try to respect '
        'your choice, it may not always be possible.',
  ),
  EducationSection(
    id: 'combined_medications',
    category: EducationCategory.combined,
    title: 'Part II — Medications',
    content:
        'If you give instructions about medications, be sure to give reasons '
        'for your decisions. If, for instance, you experienced unacceptable '
        'side effects from a particular generic or dose, you would want to be '
        'specific so that your treating doctor understands your concern. That '
        'way your doctor will be less likely to prescribe something else that '
        'is likely to cause similar problems. Likewise, if you know that a '
        'specific medication has worked for you in the past, you should be sure '
        'to include that information. If a time-released version works, but the '
        'regular brand does not, you should be sure you include that '
        'information. The more your doctor knows about you, the more likely you '
        'are to get the right treatment, faster.\n\n'
        'Be careful what you specify. Medications come in brand and generic '
        'names, and also belong to broader classes of drugs, such as "atypical '
        'antipsychotics" or "SSRIs." If you rule out an entire class of drugs, '
        'you should be aware that a new, helpful drug may come on the market '
        'that could be ruled out, even though you don\'t actually know anything '
        'about it.\n\n'
        'You may choose to let your agent make decisions related to the use of '
        'medications. If you choose this option, be sure to discuss your '
        'feelings and prior experiences with your agent.\n\n'
        'You may choose not to consent to the use of any medications. Just be '
        'aware that you will also be ruling out new medications that could be '
        'helpful in your treatment. Your Advance Directive may also be '
        'challenged if your doctor believes that you will be irreparably harmed '
        'by this choice.',
  ),
  EducationSection(
    id: 'combined_ect',
    category: EducationCategory.combined,
    title: 'Part II — Electroconvulsive Therapy (ECT)',
    content:
        'In some cases, a doctor may find that ECT would be an effective form '
        'of treatment. If you have found ECT helpful in the past, or you trust '
        'your doctor to make that decision on your behalf, you may decide to '
        'consent to this treatment in advance.\n\n'
        'You may choose to let your agent make decisions related to ECT. If '
        'you choose this option, be sure to discuss your feelings and prior '
        'experiences with ECT with your agent.\n\n'
        'If you do not wish to undergo ECT under any circumstances, you should '
        'initial the line next to "I do not consent to the administration of '
        'electro-convulsive therapy."\n\n'
        'NOTE: Your agent is NOT allowed to consent to ECT unless you '
        'initial this authorization.',
  ),
  EducationSection(
    id: 'combined_experimental',
    category: EducationCategory.combined,
    title: 'Part II — Experimental Studies',
    content:
        'Opportunities may exist for you to participate in experimental studies '
        'related to treatment of your illness. Sometimes these studies provide '
        'more data that helps doctors determine the cause or best practice for '
        'treating an illness. Sometimes the studies are based on the idea that '
        'a certain new treatment might help. If you participate in a study, '
        'you may have access to a new treatment sooner than you would '
        'otherwise. However, there may be some level of risk involved. If you '
        'want to participate in a study because your doctor believes that the '
        'potential benefits to you outweigh the potential risks, you should '
        'initial the first choice.\n\n'
        'You may choose to let your agent make decisions related to your '
        'participation for experimental studies. It is important that your '
        'agent understand the kind of studies that you would object to.\n\n'
        'If you do not want to participate in experimental studies of any kind, '
        'under any circumstances, you should initial the choice that states '
        'that you do not consent.\n\n'
        'NOTE: Your agent is NOT allowed to consent to experimental studies '
        'unless you initial this authorization.',
  ),
  EducationSection(
    id: 'combined_drug_trials',
    category: EducationCategory.combined,
    title: 'Part II — Drug Trials',
    content:
        'Similarly, you may have the opportunity to participate in a trial '
        'related to new medications. If you participate, you may have access '
        'to a new drug sooner than you would otherwise. However, there may be '
        'risks or side effects.\n\n'
        'If you want to participate in a drug trial if your doctor believes '
        'that the potential benefits to you outweigh the potential risks, you '
        'should initial the first choice.\n\n'
        'You may choose to let your agent make decisions related to your '
        'participation in drug trials. It is important that your agent '
        'understand any particular risks that you would not be willing to take '
        'so that he/she can make the decision you would make given the same '
        'information.\n\n'
        'If you do not want to participate in a drug trial of any kind, under '
        'any circumstances, you should initial the choice that states that you '
        'do not consent.\n\n'
        'NOTE: Your agent is NOT allowed to consent to research including drug '
        'trials unless you initial this authorization.',
  ),
  EducationSection(
    id: 'combined_additional',
    category: EducationCategory.combined,
    title: 'Part II — Additional Instructions or Information',
    content:
        'One of the significant benefits of filling out an Advance Directive '
        'is that you are communicating important information to your mental '
        'health care provider, agent, and others who support you. This part of '
        'your form allows you to provide information that may or may not be '
        'directly related to your mental health treatment.\n\n'
        'If there is other information that you would like your mental health '
        'care provider and agent to know you should include it here. You can '
        'attach an additional page to the form if there is not enough room to '
        'write everything you need to. Just be sure that you print or type '
        'your statements, and try to make them as clear as possible, to '
        'minimize confusion about what you want to happen. Again, if you do '
        'not have a preference about something listed or you are comfortable '
        'letting your agent make that particular decision, just leave that '
        'particular section blank.',
  ),
  EducationSection(
    id: 'combined_agent',
    category: EducationCategory.combined,
    title: 'Part III — Designating Your Agent',
    content:
        'You may name any adult who has capacity as your agent, with the '
        'following exceptions: your mental health care provider or an employee '
        'of your mental health care provider or an agent, operator, or employee '
        'of a residential facility in which you are receiving care may not '
        'serve as your agent unless they are related to you by marriage, blood '
        'or adoption.\n\n'
        'Write in the name of the person you choose, and fill in their address '
        'and phone number. You want the person to be contacted anytime, so add '
        'as much information as possible, including work and home phone '
        'numbers. The person that you choose as your agent should also sign '
        'the document to indicate that he/she accepts serving as your agent.\n\n'
        'Since your agent will be making decisions on your behalf, it is very '
        'important to choose someone you trust and to discuss your ideas and '
        'feelings in detail so that the person really understands what mental '
        'health decisions you would have made for yourself.',
  ),
  EducationSection(
    id: 'combined_alt_agent',
    category: EducationCategory.combined,
    title: 'Part III — Designating an Alternate Agent',
    content:
        'You may wish to designate an alternative person in case the first '
        'person you chose is unavailable. This is a good idea if you have '
        'another person that you trust, since people may be unavailable for a '
        'variety of reasons such as illness or travel. If you do not have '
        'anyone that you wish to name as an alternative, leave this section '
        'blank.\n\n'
        'The person that you choose as your alternative agent should also sign '
        'the document to indicate that he/she accepts serving as your agent. '
        'Your alternative agent must fill in his/her address and phone number '
        'so that they can be reached by your provider.',
  ),
  EducationSection(
    id: 'combined_authority',
    category: EducationCategory.combined,
    title: 'Part III — Authority Granted to Agent',
    content:
        'You may grant full power and authority to your agent to make all of '
        'your mental health care decisions, or you can set limits on the kinds '
        'of decisions your agent may make on your behalf. If you wish to limit '
        'the decisions your agent can make you should read each subsection '
        'carefully and initial your choice.\n\n'
        'Your agent cannot consent to electroconvulsive therapy, experimental '
        'procedures, or research unless you expressly grant those powers by '
        'initialing consent in those sections. If there is some other mental '
        'health care decision that you do not want your agent to be able to '
        'make, you may write it in. Be sure to write clearly, so there is no '
        'room for confusion.\n\n'
        'Pennsylvania law does not allow your agent to consent to psychosurgery '
        'or the termination of parental rights on your behalf, even if you are '
        'willing for your agent to have that power.',
  ),
  EducationSection(
    id: 'combined_guardian',
    category: EducationCategory.combined,
    title: 'Part IV — Nominating a Guardian',
    content:
        'If you become incapacitated, it is possible that a court may appoint '
        'a guardian to act on your behalf. Under the guardianship laws, you '
        'may nominate a guardian of your person for consideration by the court. '
        'The court will appoint your guardian in accordance with your most '
        'recent nomination except for good cause or disqualification.\n\n'
        'If you wish to name someone in your Declaration, it is important that '
        'you talk to that person about whether they feel they can serve as your '
        'guardian, because a court will not force them to serve. It is also '
        'important that you give that person a copy of your Power of Attorney '
        'and explain your wishes regarding mental health treatment.\n\n'
        'If the court appoints a guardian, that person will not be able to '
        'terminate, revoke or suspend your Declaration unless you want them to '
        'be able to. In this section, you should decide whether you want a '
        'court-appointed guardian to have that power.\n\n'
        'If the court-appointed guardian and your agent turn out to be '
        'different people, the court will give preference to allowing your '
        'mental health care agent to continue making mental health care '
        'decisions as provided in your Directive, unless you specify '
        'otherwise.',
  ),
  EducationSection(
    id: 'combined_execution',
    category: EducationCategory.combined,
    title: 'Part V — Execution',
    content:
        'You must sign and date your Combined Mental Health Care Declaration '
        'and Power of Attorney in this section. If you are unable to sign for '
        'yourself, someone else may sign on your behalf. Your document must be '
        'signed and dated by you in the presence of two witnesses. Each witness '
        'must be at least 18 years old. The witnesses may not be your agent or '
        'a person signing on your behalf.\n\n'
        'In order for your Declaration to be effective, you must be sure that '
        'the right people have access to it. Be sure to give copies of this '
        'Advance Directive to your agent, mental health care provider, and '
        'anyone else that may be notified in the event that you are found not '
        'to have capacity to make mental health care decisions. Remember that '
        'if you cancel or change your document you must let everyone know. It '
        'is a good idea to carry a card in your wallet to let people know that '
        'you have an Advance Directive.\n\n'
        'Please Note: The information in this document is not intended to '
        'constitute legal advice applicable to specific factual situations. For '
        'specific advice contact the Disabilities Law Project/Pennsylvania '
        'Protection & Advocacy (DLP/PP&A) intake line at 1-800-692-7443 '
        '(voice) or 1-877-375-7139 (TDD).',
  ),
];

// ---------------------------------------------------------------------------
// DECLARATION-ONLY INSTRUCTIONS
// ---------------------------------------------------------------------------

const _declaration = [
  EducationSection(
    id: 'decl_overview',
    category: EducationCategory.declaration,
    title: 'Declaration Overview',
    content:
        'A Declaration contains instructions to doctors, hospitals, and other '
        'mental health care providers about your treatment in the event that '
        'you become unable to make decisions or unable to communicate your '
        'wishes. A Declaration usually deals with specific situations and does '
        'not allow much flexibility for changes that come up after the document '
        'is written, such as a new type of medical crisis, new kinds of '
        'medication, or different treatment choices.\n\n'
        'You are presumed to be capable of making an Advance Directive unless '
        'you have been adjudicated incapacitated, involuntarily committed, or '
        'found to be incapable of making mental health decisions after '
        'examination by both a psychiatrist and another doctor or mental health '
        'professional.\n\n'
        'Read each section very carefully. Begin by printing your name in the '
        'blank in the introductory paragraph at the top of the form.',
  ),
  EducationSection(
    id: 'decl_effective',
    category: EducationCategory.declaration,
    title: 'When the Declaration Becomes Effective',
    content:
        'Decide when you want the Declaration to become effective. You can '
        'specify a condition, such as if you are involuntarily committed for '
        'either outpatient or inpatient care, or some other behavior or event '
        'that you know happens when you no longer have capacity to make mental '
        'health decisions, or you can specify that you want an evaluation for '
        'incapacity.\n\n'
        'If you do not choose a condition, your incapacity will be determined '
        'after examination by a psychiatrist and one of the following: another '
        'psychiatrist, psychologist, family physician, attending physician, or '
        'other mental health treatment professional. If you have doctors that '
        'you would prefer to make the evaluation, you should specify them in '
        'your Declaration.\n\n'
        'Until your condition is met, or you are found to be unable to make '
        'mental health decisions, you will make decisions for yourself.',
  ),
  EducationSection(
    id: 'decl_treatment_prefs',
    category: EducationCategory.declaration,
    title: 'Treatment Preferences',
    content:
        'Your Advance Directive will be less likely to be challenged if you '
        'include information about what you do want, as well as what you '
        'don\'t want.\n\n'
        'Remember that consenting in advance to a particular medication or '
        'treatment does not mean your doctor will prescribe that treatment or '
        'drug unless it is appropriate treatment at the time you are ill. '
        'Consent only means that you consent if it is a suitable choice at '
        'that time within the standards of medical care.\n\n'
        'Make sure to mark your preference in each section. Although you do '
        'not have to explain your choices, it is helpful if you include '
        'statements explaining why you want or don\'t want any specific '
        'treatments. If any of your choices are challenged, you will have a '
        'better chance of having your choice honored if a court understands '
        'what your reasons are for making your choice. If you do not have a '
        'preference in a given section, you may leave it blank.',
  ),
  EducationSection(
    id: 'decl_facility',
    category: EducationCategory.declaration,
    title: 'Choice of Treatment Facility',
    content:
        'If you have a preference for, or bad feelings toward, any particular '
        'hospital, list them here. Unfortunately, there are times when a '
        'particular place is already full and would be unable to accommodate '
        'you, or the treating doctor does not have privileges at the hospital '
        'you would prefer. Therefore, although your doctor will try to respect '
        'your choice, it may not always be possible.',
  ),
  EducationSection(
    id: 'decl_medications',
    category: EducationCategory.declaration,
    title: 'Medications',
    content:
        'If you give instructions about medications, be sure to give reasons '
        'for your decisions. If, for instance, you experienced unacceptable '
        'side effects from a particular generic or dose, you would want to be '
        'specific so that your treating doctor understands your concern. That '
        'way your doctor will be less likely to prescribe something else that '
        'is likely to cause similar problems. Likewise, if you know that a '
        'specific medication has worked for you in the past, you should be sure '
        'to include that information.\n\n'
        'Be careful what you specify. Medications come in brand and generic '
        'names, and also belong to broader classes of drugs, such as "atypical '
        'antipsychotics" or "SSRIs." If you rule out an entire class of drugs, '
        'you should be aware that a new, helpful drug may come on the market '
        'that could be ruled out, even though you don\'t actually know anything '
        'about it.\n\n'
        'You may choose not to consent to the use of any medications. Just be '
        'aware that you will also be ruling out new medications that could be '
        'helpful in your treatment. Your Advance Directive may also be '
        'challenged if your doctor believes that you will be irreparably harmed '
        'by this choice.',
  ),
  EducationSection(
    id: 'decl_ect',
    category: EducationCategory.declaration,
    title: 'Electroconvulsive Therapy (ECT)',
    content:
        'In some cases, a doctor may find that ECT would be an effective form '
        'of treatment. If you have found ECT helpful in the past, or you trust '
        'your doctor to make that decision on your behalf, you may decide to '
        'consent to this treatment in advance.\n\n'
        'If you do not wish to undergo ECT under any circumstances, you should '
        'initial the line next to "I do not consent to the administration of '
        'electroconvulsive therapy."',
  ),
  EducationSection(
    id: 'decl_experimental',
    category: EducationCategory.declaration,
    title: 'Experimental Studies',
    content:
        'Opportunities may exist for you to participate in experimental studies '
        'related to treatment of your illness. Sometimes these studies provide '
        'more data that help doctors determine the cause or best practice for '
        'treating an illness. Sometimes the studies are based on the idea that '
        'a certain new treatment might help. If you participate in a study, '
        'you may have access to a new treatment sooner than you would '
        'otherwise. However, there may be some level of risk involved.\n\n'
        'If you want to participate in a study because your doctor believes '
        'that the potential benefits to you outweigh the potential risks, you '
        'should initial the first choice.\n\n'
        'If you do not want to participate in experimental studies of any kind, '
        'under any circumstances, you should initial the choice that states '
        'that you do not consent.',
  ),
  EducationSection(
    id: 'decl_drug_trials',
    category: EducationCategory.declaration,
    title: 'Drug Trials',
    content:
        'Similarly, you may have the opportunity to participate in a trial '
        'related to new medications. If you participate, you may have access '
        'to a new drug sooner than you would otherwise. However, there may be '
        'risks or side effects.\n\n'
        'If you want to participate in a drug trial because your doctor '
        'believes that the potential benefits to you outweigh the potential '
        'risks, you should initial the first choice.\n\n'
        'If you do not want to participate in a drug trial of any kind, under '
        'any circumstances, you should initial the choice that states that you '
        'do not consent.',
  ),
  EducationSection(
    id: 'decl_additional',
    category: EducationCategory.declaration,
    title: 'Additional Instructions or Information',
    content:
        'One of the significant benefits of filling out an Advance Directive '
        'is that you are communicating important information to your doctor and '
        'people who support you. This part of your form allows you to provide '
        'information that may or may not be directly related to your mental '
        'health treatment. If there is other information that you would like '
        'your doctor to know, you should include it here.\n\n'
        'You can attach an additional page to the form if there is not enough '
        'room to write everything you need to. Just be sure that you print or '
        'type your statements, and try to make them as clear as possible, to '
        'minimize confusion about what you want to happen. Again, if you do '
        'not have a preference about something listed, just leave that '
        'particular section blank.',
  ),
  EducationSection(
    id: 'decl_revocation',
    category: EducationCategory.declaration,
    title: 'Revocations and Amendments',
    content:
        'Revocation means that you are canceling your Declaration. If you '
        'revoke your Declaration, your doctor will no longer have to follow '
        'the instructions that you gave in the document. You may change or '
        'revoke your Declaration at any time, as long as you have capacity to '
        'make mental health decisions when you make the change or revocation. '
        'You may revoke a specific instruction without revoking the entire '
        'document.\n\n'
        'If you are currently under an involuntary commitment, and you want to '
        'change or revoke your Declaration, you will need to request an '
        'evaluation to determine if you are capable of making mental health '
        'decisions. If you are found to have the capacity to make mental health '
        'decisions, you will be able to revoke or change your Declaration, even '
        'though you are in the hospital.\n\n'
        'You may revoke your Declaration orally or in writing. It becomes '
        'effective as soon as you communicate your revocation to your treating '
        'doctor. It is best to make any changes or revocation in writing, '
        'because then there is a clear record of your wishes.\n\n'
        'If you make a new Declaration, you should be sure to notify your '
        'doctor and support people that you have revoked the old one. Your '
        'Declaration will automatically expire two years from the date you made '
        'it, unless you are unable to make mental health decisions for yourself '
        'at the time it would expire. In that case, it will remain in force '
        'until you are able to make decisions for yourself.\n\n'
        'To amend your Declaration means that you make changes to it. Any '
        'changes must be made in writing and be signed and witnessed by two '
        'individuals in the same way as the original document.',
  ),
  EducationSection(
    id: 'decl_guardian',
    category: EducationCategory.declaration,
    title: 'Preference as to a Court-Appointed Guardian',
    content:
        'If you become incapacitated, it is possible that a court may appoint '
        'a guardian to act on your behalf. Under the guardianship laws, you '
        'may nominate a guardian of your person for consideration by the court. '
        'The court will appoint your guardian in accordance with your most '
        'recent nomination except for good cause or disqualification.\n\n'
        'If you wish to name someone in your Declaration, it is important that '
        'you talk to that person about whether they feel they can serve as your '
        'guardian, because a court will not force them to serve.\n\n'
        'If the court appoints a guardian, that person will not be able to '
        'terminate, revoke or suspend your Declaration unless you want them to '
        'be able to. In this section, you should decide whether you want a '
        'court-appointed guardian to have that power.',
  ),
  EducationSection(
    id: 'decl_execution',
    category: EducationCategory.declaration,
    title: 'Execution',
    content:
        'You must sign and date your Declaration in this section. If you are '
        'unable to sign for yourself, someone else may sign on your behalf. '
        'Your document must be signed and dated by you in the presence of two '
        'witnesses. Each witness must be at least 18 years old. If you are '
        'unable to sign the document yourself, you may have someone else sign '
        'on your behalf, but that person may not also be a witness.\n\n'
        'In order for your Declaration to be effective, you must be sure that '
        'the right people have access to it. Be sure to give copies of this '
        'Advance Directive to your mental health care provider, and anyone else '
        'that may be notified in the event that you are found not to have '
        'capacity to make mental health care decisions.\n\n'
        'Please Note: The information in this document is not intended to '
        'constitute legal advice applicable to specific factual situations. For '
        'specific advice contact the Disabilities Law Project/Pennsylvania '
        'Protection & Advocacy (DLP/PP&A) intake line at 1-800-692-7443 '
        '(voice) or 1-877-375-7139 (TDD).',
  ),
];

// ---------------------------------------------------------------------------
// POWER OF ATTORNEY INSTRUCTIONS
// ---------------------------------------------------------------------------

const _poa = [
  EducationSection(
    id: 'poa_overview',
    category: EducationCategory.poa,
    title: 'Power of Attorney Overview',
    content:
        'A Power of Attorney allows you to designate someone else, called an '
        'agent, to make treatment decisions for you in the event of a mental '
        'health crisis. A Power of Attorney provides flexibility to deal with '
        'a situation as it occurs rather than attempting to anticipate every '
        'possible situation in advance. When using a Power of Attorney it is '
        'very important to choose someone you trust as your agent and to spend '
        'time with that person explaining your feelings about treatment '
        'choices. Your doctor or his/her employee, or an owner, operator, or '
        'employee of a residential facility where you are living cannot serve '
        'as an agent.\n\n'
        'You are presumed to be capable of making an Advance Directive unless '
        'you have been adjudicated incapacitated, involuntarily committed, or '
        'found to be incapable of making mental health decisions after '
        'examination by both a psychiatrist and another doctor or mental '
        'health professional.\n\n'
        'Read each section very carefully. Begin by printing your name in the '
        'blank in the introductory paragraph at the top of the form.',
  ),
  EducationSection(
    id: 'poa_agent',
    category: EducationCategory.poa,
    title: 'Designation of Agent',
    content:
        'You may name any adult who has capacity as your agent, with the '
        'following exceptions: your mental health care provider or an employee '
        'of your mental health care provider or an agent, operator, or employee '
        'of a residential facility in which you are receiving care may not '
        'serve as your agent unless they are related to you by marriage, blood '
        'or adoption.\n\n'
        'Write in the name of the person you choose, and fill in their address '
        'and phone number. You want the person to be contacted anytime, so add '
        'as much information as possible, including work and home phone '
        'numbers. The person that you choose as your agent should also sign '
        'the document to indicate that he/she accepts serving as your agent.\n\n'
        'Since your agent will be making decisions on your behalf, it is very '
        'important to choose someone you trust and to discuss your ideas and '
        'feelings in detail so that the person really understands what mental '
        'health decisions you would have made for yourself.',
  ),
  EducationSection(
    id: 'poa_alt_agent',
    category: EducationCategory.poa,
    title: 'Designation of an Alternative Agent',
    content:
        'You may wish to designate an alternative person in case the first '
        'person you chose is unavailable. This is a good idea if you have '
        'another person that you trust, since people may be unavailable for a '
        'variety of reasons such as illness or travel. If you do not have '
        'anyone that you wish to name as an alternative, leave this section '
        'blank.\n\n'
        'The person that you choose as your alternative agent should also sign '
        'the document to indicate that he/she accepts serving as your agent. '
        'Your alternative agent should fill in his/her address and phone number '
        'so that they can be reached by your provider.',
  ),
  EducationSection(
    id: 'poa_effective',
    category: EducationCategory.poa,
    title: 'When the Power of Attorney Becomes Effective',
    content:
        'Decide when you want the Power of Attorney to become effective. You '
        'can specify a condition, such as if you are involuntarily committed '
        'for either outpatient or inpatient care, or some other behavior or '
        'event that you know happens when you no longer have capacity to make '
        'mental health decisions, or you can specify that you want an '
        'evaluation for incapacity.\n\n'
        'If you do not choose a condition, your incapacity will be determined '
        'after examination by a psychiatrist and one of the following: another '
        'psychiatrist, psychologist, family physician, attending physician, or '
        'other mental health treatment professional. If you have doctors that '
        'you would prefer to make the evaluation, you should specify them in '
        'your Power of Attorney.\n\n'
        'Until your condition is met, or you are found to be unable to make '
        'mental health decisions, you will make decisions for yourself.',
  ),
  EducationSection(
    id: 'poa_authority',
    category: EducationCategory.poa,
    title: 'Authority Granted to Your Agent',
    content:
        'You may grant full power and authority to your agent to make all of '
        'your mental health care decisions, or you can set limits on the kinds '
        'of decisions your agent may make on your behalf. If you wish to limit '
        'the decisions your agent can make you should read each subsection '
        'carefully. If there is some other mental health care decision that '
        'you do not want your agent to be able to make, you may write it in.\n\n'
        'Pennsylvania law does not allow your agent to consent to psychosurgery '
        'or the termination of parental rights on your behalf, even if you are '
        'willing for your agent to have that power.',
  ),
  EducationSection(
    id: 'poa_facility',
    category: EducationCategory.poa,
    title: 'Choice of Treatment Facility',
    content:
        'If you have a preference for, or bad feelings toward, any particular '
        'hospital, list them here. Unfortunately, there are times when a '
        'particular place is already full and would be unable to accommodate '
        'you, or the treating doctor does not have privileges at the hospital '
        'you would prefer. Therefore, although your doctor will try to respect '
        'your choice, it may not always be possible.',
  ),
  EducationSection(
    id: 'poa_medications',
    category: EducationCategory.poa,
    title: 'Preferences Regarding Medications',
    content:
        'If you give instructions about medications, be sure to give reasons '
        'for your decisions. If, for instance, you experienced unacceptable '
        'side effects from a particular generic or dose, you would want to be '
        'specific so that your treating doctor understands your concern. That '
        'way your doctor will be less likely to prescribe something else that '
        'is likely to cause similar problems.\n\n'
        'Be careful what you specify. Medications come in brand and generic '
        'names, and also belong to broader classes of drugs, such as "atypical '
        'antipsychotics" or "SSRIs." If you rule out an entire class of drugs, '
        'you should be aware that a new, helpful drug may come on the market '
        'that could be ruled out, even though you don\'t actually know anything '
        'about it.\n\n'
        'Giving your agent authority to make medication decisions allows more '
        'flexibility to deal with future situations. For instance, a new drug '
        'may come on the market that is not currently available. By allowing '
        'your agent to make the decision at the time of your incapacity means '
        'that your agent will have the most up-to-date information on which to '
        'base decisions.',
  ),
  EducationSection(
    id: 'poa_ect',
    category: EducationCategory.poa,
    title: 'Preferences Regarding ECT',
    content:
        'In some cases, a doctor may find that ECT would be an effective form '
        'of treatment. If you have found ECT helpful in the past, and/or you '
        'trust your agent to make that decision if your doctor thinks it may '
        'help, you should initial the line next to "my agent is authorized to '
        'consent to the administration of electroconvulsive therapy."\n\n'
        'If you do not wish to undergo ECT under any circumstances, you should '
        'initial the line next to "I do not consent to the administration of '
        'electroconvulsive therapy."\n\n'
        'NOTE: Your agent MAY NOT consent to ECT unless you initial this '
        'authorization.',
  ),
  EducationSection(
    id: 'poa_experimental',
    category: EducationCategory.poa,
    title: 'Preferences for Experimental Studies',
    content:
        'Opportunities may exist for you to participate in experimental studies '
        'related to treatment of your illness. If you want to participate in a '
        'study because your doctor believes that the potential benefits to you '
        'outweigh the potential risks, you should initial the first choice.\n\n'
        'If you do not want to participate in experimental studies of any kind, '
        'under any circumstances, you should initial the choice that states '
        'that you do not consent.\n\n'
        'NOTE: Your agent MAY NOT consent to experimental studies unless you '
        'initial this authorization.',
  ),
  EducationSection(
    id: 'poa_drug_trials',
    category: EducationCategory.poa,
    title: 'Preferences Regarding Drug Trials',
    content:
        'Similarly, you may have the opportunity to participate in a trial '
        'related to new medications. If you participate, you may have access '
        'to a new drug sooner than you would otherwise. However, there may be '
        'risks or side effects. If you want to participate in a drug trial '
        'because your doctor believes that the potential benefits to you '
        'outweigh the potential risks, you should initial the first choice.\n\n'
        'If you do not want to participate in a drug trial of any kind, under '
        'any circumstances, you should initial the choice that states your '
        'agent does not have your authorization to consent on your behalf.',
  ),
  EducationSection(
    id: 'poa_revocation',
    category: EducationCategory.poa,
    title: 'Revocations and Amendments',
    content:
        'Revocation means that you are canceling your Power of Attorney. If '
        'you revoke your Power of Attorney, your agent will no longer be '
        'representing you, and your doctor will no longer have to follow the '
        'instructions that your agent gives. You may change or revoke your '
        'Power of Attorney at any time, as long as you have capacity to make '
        'mental health decisions when you make the change or revocation. You '
        'may revoke a specific instruction without revoking the entire '
        'document.\n\n'
        'If you are currently under an involuntary commitment, and you want to '
        'change or revoke your Power of Attorney, you will need to request an '
        'evaluation to determine if you are capable of making mental health '
        'decisions. If you are found to have the capacity, you will be able to '
        'revoke or change your Power of Attorney, even though you are in the '
        'hospital.\n\n'
        'You may revoke your Power of Attorney orally or in writing. It becomes '
        'effective as soon as you communicate your revocation to your treating '
        'doctor. It is best to make any changes or revocation in writing, '
        'because then there is a clear record of your wishes.\n\n'
        'If you make a new Power of Attorney, you should be sure to notify '
        'your doctor and support people that you have revoked the old one. '
        'Your Power of Attorney will automatically expire two years from the '
        'date you made it, unless you are unable to make mental health '
        'decisions for yourself at the time it would expire. In that case, it '
        'will remain in force until you are able to make decisions for '
        'yourself.',
  ),
  EducationSection(
    id: 'poa_guardian',
    category: EducationCategory.poa,
    title: 'Preference as to a Court-Appointed Guardian',
    content:
        'If you become incapacitated, it is possible that a court may appoint '
        'a guardian to act on your behalf. Under the guardianship laws, you '
        'may nominate a guardian of your person for consideration by the court. '
        'The court will appoint your guardian in accordance with your most '
        'recent nomination except for good cause or disqualification.\n\n'
        'If you wish to name someone, it is important that you talk to that '
        'person about whether they feel they can serve as your guardian, '
        'because a court will not force them to serve. It is also important '
        'that you give that person a copy of your Power of Attorney and explain '
        'your wishes regarding mental health treatment.',
  ),
  EducationSection(
    id: 'poa_execution',
    category: EducationCategory.poa,
    title: 'Execution',
    content:
        'You must sign and date your Power of Attorney in this section. If you '
        'are unable to sign for yourself, someone else may sign on your behalf. '
        'Your document must be signed and dated by you in the presence of two '
        'witnesses. Each witness must be at least 18 years old.\n\n'
        'In order for your Power of Attorney to be effective, you must be sure '
        'that the right people have access to it. Be sure to give copies to '
        'your agent, mental health care provider, and anyone else that may be '
        'notified in the event that you are found not to have capacity to make '
        'mental health care decisions. Remember that if you cancel or change '
        'your document you must let everyone know.\n\n'
        'Please Note: The information in this document is not intended to '
        'constitute legal advice applicable to specific factual situations. For '
        'specific advice contact the Disabilities Law Project/Pennsylvania '
        'Protection & Advocacy (DLP/PP&A) intake line at 1-800-692-7443 '
        '(voice) or 1-877-375-7139 (TDD).',
  ),
];

// ---------------------------------------------------------------------------
// GLOSSARY
// ---------------------------------------------------------------------------

const _glossary = [
  EducationSection(
    id: 'gloss_agent',
    category: EducationCategory.glossary,
    title: 'Agent',
    content:
        'An individual named by a person in a Mental Health Care Power of '
        'Attorney who will make mental health care decisions on behalf of '
        'the person.',
  ),
  EducationSection(
    id: 'gloss_amend',
    category: EducationCategory.glossary,
    title: 'Amend',
    content: 'To change or modify by adding or subtracting language.',
  ),
  EducationSection(
    id: 'gloss_attending_physician',
    category: EducationCategory.glossary,
    title: 'Attending Physician',
    content:
        'A physician who has primary responsibility for the treatment and care '
        'of the person making the Advance Directive.',
  ),
  EducationSection(
    id: 'glossary_capacity',
    category: EducationCategory.glossary,
    title: 'Capacity',
    content:
        'A clinical determination that a person can understand, weigh, and '
        'communicate a decision about their own care. Capacity is decision-'
        'specific (you may have capacity for one decision and not another) '
        'and time-specific (it can come and go). Under PA Act 194, capacity '
        'is determined by a qualified clinician and documented in the '
        'medical record.',
  ),
  EducationSection(
    id: 'glossary_chapter_54_vs_58',
    category: EducationCategory.glossary,
    title: 'Chapter 54 vs Chapter 58 (the two PA advance-directive laws)',
    content:
        'Pennsylvania has two parallel advance-directive statutes in '
        'Title 20 of the Consolidated Statutes:\n\n'
        '• **Chapter 54 — Health Care (Act 169 of 2006).** General '
        'health-care decisions: living wills, end-of-life care, '
        'life-preserving treatment, surgery consent, general '
        'health-care power of attorney, default health-care '
        'representative hierarchy. Provider-duty section: §5462.\n\n'
        '• **Chapter 58 — Mental Health Care (Act 194 of 2004).** '
        'Mental-health treatment decisions: psychiatric '
        'hospitalization, psychotropic medications, ECT, experimental '
        'psychiatric studies, drug trials, facility preferences, '
        'mental-health agent. Provider-duty section: §5842. This is '
        'the law your MHAD is written under.\n\n'
        'Both chapters use mandatory "shall comply" language for '
        'provider duties. The same person can be named as your agent '
        'under both — and often it is simplest if they are. See the '
        'Supplementary section "How Chapter 54 and Chapter 58 work '
        'together" for how each statute applies in specific clinical '
        'situations.',
  ),
  EducationSection(
    id: 'glossary_competence',
    category: EducationCategory.glossary,
    title: 'Competence (vs. capacity)',
    content:
        '"Competence" is a *legal* status determined by a court (for '
        'example, after a guardianship hearing). "Capacity" is a *clinical* '
        'judgment that can be made on a moment-by-moment basis by a '
        'physician, psychologist, or certified RN practitioner. Your MHAD '
        'is triggered by a clinical finding of incapacity — it does not '
        'require a court declaration of incompetence.',
  ),
  EducationSection(
    id: 'glossary_county_mh_idd',
    category: EducationCategory.glossary,
    title: 'County MH/IDD program',
    content:
        'Each PA county operates a Mental Health / Intellectual '
        'Disabilities (MH/IDD) program that serves as the local entry '
        'point for public mental-health services, crisis intervention, '
        'and case management. Your county MH/IDD office is often a useful '
        'contact to list in your directive — they can help coordinate '
        'care across providers.',
  ),
  EducationSection(
    id: 'gloss_declaration',
    category: EducationCategory.glossary,
    title: 'Declaration',
    content:
        'A writing which expresses a person\'s wishes and instructions for '
        'mental health care or other subjects.',
  ),
  EducationSection(
    id: 'gloss_execute',
    category: EducationCategory.glossary,
    title: 'Execute',
    content: 'To sign, date, and have the signature witnessed.',
  ),
  EducationSection(
    id: 'gloss_incapacity',
    category: EducationCategory.glossary,
    title: 'Incapacity',
    content:
        'A clinical determination that a person lacks sufficient understanding '
        'or ability to make or communicate responsible decisions about mental '
        'health treatment — the absence of capacity for a given decision at a '
        'given time. A finding of incapacity is what activates the operative '
        'parts of your MHAD.\n\n'
        'Under PA Act 194, incapacity is determined by a psychiatrist and one '
        'additional qualified professional (another psychiatrist, licensed '
        'psychologist, family physician, attending physician, or mental health '
        'treatment professional).\n\n'
        'Incapacity is NOT the same as a psychiatric diagnosis, an involuntary '
        'commitment, or a finding of legal incompetence — a person can be '
        'hospitalised under section 302 and still have capacity for some '
        'decisions.',
  ),
  EducationSection(
    id: 'gloss_involuntary_commitment',
    category: EducationCategory.glossary,
    title: 'Involuntary Commitment',
    content:
        'A legal process under Pennsylvania\'s Mental Health Procedures Act '
        '(50 P.S. §7301 et seq.) by which a person may be hospitalized for '
        'psychiatric treatment without their consent, typically when they '
        'pose a clear and present danger to themselves or others. A person '
        'who is involuntarily committed cannot execute a new Mental Health '
        'Advance Directive during the commitment period, but a previously '
        'executed directive remains in effect.',
  ),
  EducationSection(
    id: 'glossary_least_restrictive',
    category: EducationCategory.glossary,
    title: 'Least restrictive alternative',
    content:
        'A foundational principle in PA mental-health law: treatment '
        'should be provided in the setting and manner that imposes the '
        'least limit on the person\'s freedom consistent with effective '
        'care. Your directive can specify preferred settings (outpatient, '
        'partial hospitalisation, specific facilities) that align with '
        'this principle.',
  ),
  EducationSection(
    id: 'gloss_mhad',
    category: EducationCategory.glossary,
    title: 'Mental Health Advance Directive',
    content:
        'A document that allows a person to make choices regarding mental '
        'health treatment known in the event that the person is incapacitated '
        'by his/her mental illness. In effect, the person is giving or '
        'withholding consent to treatment before treatment is needed.',
  ),
  EducationSection(
    id: 'gloss_mental_health_care',
    category: EducationCategory.glossary,
    title: 'Mental Health Care',
    content:
        'Any care, treatment, service or procedure to maintain, diagnose, '
        'treat, or provide for mental health, including any medication program '
        'and therapeutic treatment.',
  ),
  EducationSection(
    id: 'gloss_provider',
    category: EducationCategory.glossary,
    title: 'Mental Health Care Provider',
    content:
        'A person who is licensed, certified or otherwise authorized by the '
        'laws of Pennsylvania to provide mental health care.',
  ),
  EducationSection(
    id: 'gloss_treatment_professional',
    category: EducationCategory.glossary,
    title: 'Mental Health Treatment Professional',
    content:
        'A person trained and licensed in psychiatry, social work, psychology, '
        'or nursing who has a graduate degree and clinical experience.',
  ),
  EducationSection(
    id: 'glossary_pmhca',
    category: EducationCategory.glossary,
    title: 'PMHCA — PA Mental Health Consumers\' Association',
    content:
        'A statewide consumer-run organisation providing peer support, '
        'advocacy, and self-help resources for Pennsylvanians with mental-'
        'health conditions. Helpline: 1-800-887-6422. They are a useful '
        'point of contact for peer specialists, recovery groups, and '
        'community resources to name in your directive\'s additional-'
        'instructions section.',
  ),
  EducationSection(
    id: 'gloss_poa',
    category: EducationCategory.glossary,
    title: 'Power of Attorney',
    content:
        'A writing made by a person naming someone else to make mental health '
        'care decisions on behalf of the person.',
  ),
  EducationSection(
    id: 'glossary_principal',
    category: EducationCategory.glossary,
    title: 'Principal',
    content:
        'The person creating the directive — that is, you. The term comes '
        'from the language of legal instruments: the principal is the one '
        'whose wishes are being expressed and on whose behalf the agent '
        'acts.',
  ),
  EducationSection(
    id: 'gloss_psychotropic',
    category: EducationCategory.glossary,
    title: 'Psychotropic Medication',
    content:
        'Medications that affect the mind, emotions, or behavior. Categories '
        'include antidepressants (e.g., SSRIs, SNRIs), antipsychotics '
        '(typical and atypical), mood stabilizers (e.g., lithium, '
        'valproate), anti-anxiety medications (e.g., benzodiazepines), and '
        'stimulants. In your directive, you may specify preferences or '
        'refusals for specific psychotropic medications.',
  ),
  EducationSection(
    id: 'gloss_revoke',
    category: EducationCategory.glossary,
    title: 'Revoke',
    content: 'To cancel or end.',
  ),
  EducationSection(
    id: 'glossary_section_302',
    category: EducationCategory.glossary,
    title: 'Section 302 (emergency involuntary examination)',
    content:
        'Under 50 P.S. § 7302 of the Mental Health Procedures Act, a '
        'person may be involuntarily taken for psychiatric examination '
        'and treatment for up to **120 hours** (5 days) when there is '
        'clear and present danger to self or others. Initiated by '
        'physician, peace officer, or written petition by a responsible '
        'adult. A 302 admission does not by itself trigger your MHAD; an '
        'incapacity determination does.',
  ),
  EducationSection(
    id: 'glossary_section_303',
    category: EducationCategory.glossary,
    title: 'Section 303 (extended emergency treatment)',
    content:
        'Under 50 P.S. § 7303, a court may order extended involuntary '
        'treatment for up to **20 days** following a 302. Requires a '
        'hearing in front of a mental-health review officer within 120 '
        'hours of the 302 admission. You have the right to counsel and '
        'to be present.',
  ),
  EducationSection(
    id: 'glossary_shall_comply',
    category: EducationCategory.glossary,
    title: '"Shall comply" (statutory language)',
    content:
        'In statutory drafting, the word "shall" creates a mandatory '
        'duty — it is not the same as "may" or "should." When a PA '
        'statute says a physician or provider "shall comply" with an '
        'agent\'s decision, the law is requiring compliance, not '
        'suggesting it.\n\n'
        'Two PA statutes use this exact construction for advance '
        'directives:\n'
        '• **20 Pa.C.S. §5842** (Chapter 58 — Mental Health Care): '
        'attending physicians and mental health care providers "shall '
        'comply" with decisions made by a mental health care agent.\n'
        '• **20 Pa.C.S. §5462(c)(1)** (Chapter 54 — Health Care): '
        'attending physicians and health-care providers "shall comply" '
        'with decisions made by a health-care agent or representative, '
        'to the same extent as if the principal had made them, outside '
        'a narrow life-preserving carve-out.\n\n'
        'Patient handouts that describe directives as "guidelines only" '
        'or say "no law guarantees compliance" do not change the '
        'mandatory force of the statute. They describe outcomes (which '
        'depend on facts and exceptions), not the default rule (which '
        'is compulsory compliance subject to a defined transfer '
        'process).',
  ),
  EducationSection(
    id: 'gloss_substituted_judgment',
    category: EducationCategory.glossary,
    title: 'Substituted Judgment',
    content:
        'The legal standard used by mental health care agents when making '
        'decisions on behalf of the principal. Under PA Act 194 §5836, the '
        'agent must decide based on what the principal WOULD want — not what '
        'the agent personally thinks is best for the principal.\n\n'
        'This means the agent should:\n'
        '• Follow the specific instructions in the directive\n'
        '• Consider the principal\'s known values, beliefs, and preferences\n'
        '• Make the decision the principal would make if capable\n\n'
        'This is different from the "best interests" standard used in some '
        'other contexts, which focuses on what an objective person would '
        'consider best for the patient.',
  ),
  EducationSection(
    id: 'glossary_treatment_over_objection',
    category: EducationCategory.glossary,
    title: 'Treatment over objection',
    content:
        'Treatment provided despite the patient\'s contemporaneous '
        'objection. Under PA law and constitutional protections, treatment '
        'over objection is generally permitted only with strict procedural '
        'safeguards (court order or qualifying involuntary-commitment '
        'status) and only for treatments where the benefit substantially '
        'outweighs the burden. Your directive\'s preferences are part of '
        'the analysis a court would weigh.',
  ),
];

// ---------------------------------------------------------------------------
// SUPPLEMENTARY — Statutory content from 20 Pa.C.S. Chapter 58 (Act 194)
// not included in the PDF booklet
// ---------------------------------------------------------------------------

const _supplementary = [
  EducationSection(
    id: 'supp_governing_law',
    category: EducationCategory.supplementary,
    title: 'Governing Law & Execution Requirements',
    content:
        'Pennsylvania Mental Health Advance Directives are governed by '
        '20 Pa.C.S. Chapter 58 (Mental Health Care), enacted by Act 194 '
        'of 2004 (P.L.1525, No.194), effective January 29, 2005.\n\n'
        '**Execution Requirements**\n\n'
        'The specific execution requirements are found in:\n'
        '• 20 Pa.C.S. §5822 — for mental health declarations\n'
        '• 20 Pa.C.S. §5832 — for mental health powers of attorney\n\n'
        'To execute a valid directive, you need:\n'
        '1. Your signature (or mark) as the declarant/principal\n'
        '2. The date of execution\n'
        '3. At least two witnesses (each age 18 or older) who watch you '
        'sign the document and then sign it themselves in each other\'s '
        'presence\n\n'
        'Under §5822, an individual who signs a declaration on behalf of '
        'and at the direction of a declarant may not witness the '
        'declaration. A mental health care provider (and its agent) may '
        'not sign on behalf of the declarant if they provide services to '
        'the declarant.\n\n'
        '**No Notarization Required**\n\n'
        'There is no notarization requirement anywhere in Chapter 58. '
        'Your directive must be signed and dated by you and at least two '
        'witnesses — that is all. No notary, no lawyer, no fee.\n\n'
        'For contrast, Pennsylvania\'s general power of attorney statute '
        '(20 Pa.C.S. §5601) does require notarization. The legislature '
        'deliberately omitted that requirement from Chapter 58 for '
        'mental health advance directives. If both witnessed and '
        'notarized, the document is more likely to be honored by the '
        'laws of other states — but notarization is entirely optional '
        'under PA law.\n\n'
        '**Amendments Follow the Same Process**\n\n'
        'Any changes to your directive must also be made in writing and '
        'signed and witnessed by two individuals in the same way as the '
        'original document.\n\n'
        'Sources: Disability Rights Pennsylvania official guidance; '
        'Allegheny County MHAD Agent Guide; MHAPA.',
  ),
  EducationSection(
    id: 'supp_provider_obligations',
    category: EducationCategory.supplementary,
    title: 'Provider Obligations Under Act 194 — "shall comply"',
    content:
        '**The statutory rule.** Under 20 Pa.C.S. §5842 (Duties of '
        'Attending Physician and Mental Health Care Provider), the law '
        'uses mandatory language: "An attending physician or mental '
        'health care provider **shall comply** with a mental health '
        'care decision made by a mental health care agent."\n\n'
        'In statutory drafting, "shall" creates a duty — it is not '
        'permissive language. The agent\'s decision must be honored to '
        'the same extent as if you had made it yourself. This default '
        'rule is subject only to the specific exceptions in §5804 '
        '(conscience, clinical standards, unavailability, institutional '
        'policy) and any limitations you yourself wrote into the '
        'mental-health power of attorney.\n\n'
        '**The transfer mechanism (§5804).** A provider who cannot in '
        'good conscience comply with a directive does not gain a '
        'unilateral override. The provider must instead:\n'
        '• Immediately inform you (if competent), your agent, the '
        'substitute named in your declaration, and any guardian;\n'
        '• Document the reasons for noncompliance in the medical record;\n'
        '• Make a reasonable effort to transfer your care to a provider '
        'who will comply;\n'
        '• Continue treating you per the directive while the transfer '
        'is pending;\n'
        '• Allow discharge if no complying provider accepts transfer.\n\n'
        '**Other duties (§5807).** Providers must inquire about the '
        'existence of an MHAD at intake or initial assessment, and must '
        'inform discharged patients about the availability of '
        'declarations and powers of attorney. A provider may not require '
        'a directive as a condition of treatment, nor base treatment '
        'acceptance or refusal on whether a directive exists.\n\n'
        '**Good-faith immunity (§5805).** A provider who acts in good '
        'faith and consistent with Chapter 58 is not subject to criminal '
        'or civil liability, professional discipline, or administrative '
        'sanctions for following an agent\'s direction — so long as the '
        'direction is not clearly contrary to the terms of the '
        'mental-health power of attorney. The statute therefore both '
        'requires compliance AND protects the provider who complies.\n\n'
        '**Parallel rule for general health care.** Chapter 54 (Act 169 '
        'of 2006) contains the same framework for general health-care '
        'directives at §5462(c)(1): outside a narrow life-preserving '
        'carve-out, the attending physician or health-care provider '
        '"shall comply with a health care decision made by a health '
        'care agent or health care representative to the same extent as '
        'if the decision had been made by the principal." The two '
        'chapters operate in parallel — see the FAQ "How is my MHAD '
        'different from a regular health-care directive?" for the '
        'practical interaction.\n\n'
        '**Sources:** 20 Pa.C.S. §§ 5804, 5805, 5807, 5842 (Chapter 58 — '
        'Act 194 of 2004); 20 Pa.C.S. § 5462(c)(1) (Chapter 54 — Act '
        '169 of 2006).',
  ),
  EducationSection(
    id: 'supp_coverage_policy_limits',
    category: EducationCategory.supplementary,
    title: 'Insurance, coverage, and provider-policy limits',
    content:
        'Your directive is about **consent** — it makes your wishes known and '
        'binding under the "shall comply" rule — but it is not a blank check '
        'that forces a provider or insurer to give you anything you write '
        'down. "Provider policies or coverage limits" is the statute\'s way of '
        'saying a provider still has to honor its insurance contract and its '
        'own program rules. Your consent and preferences still matter; they '
        'just cannot override:\n\n'
        '• **Insurance contracts** — what the plan will pay for.\n'
        '• **Provider–insurer contracts** — what the provider may bill or '
        'offer under that benefit.\n'
        '• **Facility / program rules** — who a setting can accept and what '
        'level of care it provides.\n\n'
        '**Drug-formulary example.** If your directive asks for a specific '
        'brand-name drug your plan does not cover, the doctor is not forced to '
        'break insurance rules to obtain it. They may prescribe a covered '
        'equivalent that is on the formulary — unless you specifically '
        'withheld consent to that alternative — or pursue a '
        'prior-authorization appeal, or help transfer you to a provider who '
        'can honor the request within its policies.\n\n'
        '**Level-of-care example.** If your directive says "treat me only in a '
        'small private facility" but you arrive in crisis at a large public '
        'hospital, that hospital is not required to break its admission or '
        'transfer policies or absorb uncovered costs. It must treat you within '
        'its own rules and your coverage and make reasonable efforts to '
        'transfer you if that is feasible.\n\n'
        '**Non-covered or excluded services.** If your directive demands a '
        'service your plan excludes — for example an out-of-state residential '
        'program, daily one-on-one inpatient psychotherapy, or a treatment '
        'the plan labels experimental — a provider cannot ignore those '
        'coverage and contract limits simply because the directive says so.\n\n'
        '**What the provider still owes you.** Even when policy or coverage '
        'blocks part of your directive, the provider must tell you or your '
        'agent as soon as possible, make every reasonable effort to transfer '
        'you to a provider or facility that can honor it, and treat you as '
        'consistently with the directive as possible in the meantime.\n\n'
        '**Tip: write policy-savvy instructions.** Instead of demanding a '
        'single option, give ranked, flexible choices — for example, "if Drug '
        'X is unavailable or not covered, use Y or Z, but never A or B." That '
        'way you work with coverage limits instead of being blindsided by '
        'them.',
  ),
  EducationSection(
    id: 'supp_emergency_override',
    category: EducationCategory.supplementary,
    title: 'Emergency Override & Section 302',
    content:
        'If you are voluntarily committed (age 14 or older), your refusal of '
        'psychotropic medication — including by MHAD instruction — MUST be '
        'honored UNLESS you pose an imminent threat of danger to yourself or '
        'others.\n\n'
        'In an emergency, your protest may be overridden ONLY when staff also '
        'initiate involuntary emergency commitment under Section 302 of the '
        'Mental Health Procedures Act.\n\n'
        'In non-emergency situations, if lack of medication poses a serious '
        'danger or renders you unable to care for yourself, the provider must '
        'initiate court-ordered involuntary commitment under Section 304(c) '
        'before overriding your directive.\n\n'
        'Either way, a valid directive that refuses a specific medication is '
        'treated as a **contemporaneous objection** and must be honored for as '
        'long as the directive remains valid. If staff believe they cannot '
        'effectively treat you without that medication, they must either '
        'transfer you to a physician or facility willing to honor the '
        'directive, or seek a court order authorizing treatment contrary to it '
        '— being involuntarily committed does not, by itself, create a blanket '
        'exception that lets staff ignore an otherwise-valid directive.',
  ),
  EducationSection(
    id: 'supp_substituted_judgment',
    category: EducationCategory.supplementary,
    title: 'The Substituted Judgment Standard',
    content:
        'Under 20 Pa.C.S. §5836, your agent must make decisions based on '
        'your understood instructions — including prior declarations, and '
        'written or verbal directions you have given.\n\n'
        'If no specific instructions cover a situation, your agent should '
        'assess what YOU would have wanted (your preferences), not what the '
        'agent thinks is "best." This is called the "substituted judgment" '
        'standard, as opposed to a "best interests" standard.\n\n'
        'Your agent has the same rights as you to request, examine, copy, and '
        'consent to disclosure of your mental health records (unless you '
        'limited this in the POA). Disclosure does not waive evidentiary '
        'privilege or confidentiality. Your agent may disclose information '
        'only as reasonably necessary to fulfill their obligations or as '
        'required by law.',
  ),
  EducationSection(
    id: 'supp_agent_removal',
    category: EducationCategory.supplementary,
    title: 'When an Agent Loses Authority (Removal & Divorce)',
    content:
        'Under 20 Pa.C.S. §5837, an agent may be removed for any of the '
        'following reasons:\n'
        '• Death or incapacity of the agent\n'
        '• Noncompliance with the power of attorney\n'
        '• Physical assault or threats against you (the principal)\n'
        '• Coercion of you\n'
        '• Voluntary withdrawal — the agent must notify you, and if the POA '
        'is in effect, must also notify your providers\n'
        '• Divorce (see below)\n\n'
        'Third parties may challenge an agent\'s authority by filing a '
        'petition in orphan\'s court.\n\n'
        '**Divorce automatically revokes a spouse-agent.** Under 20 Pa.C.S. '
        '§5838, if you designated your spouse as your agent, that designation '
        'is AUTOMATICALLY REVOKED when either spouse files a divorce action. '
        'The only exception is if your power of attorney clearly shows your '
        'intent for the designation to continue despite a divorce filing. If '
        'your spouse is your agent and you are considering divorce, plan to '
        'designate a new agent.',
  ),
  EducationSection(
    id: 'supp_penalties',
    category: EducationCategory.supplementary,
    title: 'Criminal Penalties for Tampering',
    content:
        'Under 20 Pa.C.S. §5806, it is a third-degree felony to willfully:\n'
        '• Conceal, cancel, alter, deface, obliterate, or damage a '
        'declaration without the declarant\'s consent\n'
        '• Do the same to a power of attorney, amendment, or revocation '
        'without the principal\'s consent\n'
        '• Cause execution of a directive through undue influence, fraud, '
        'or duress\n'
        '• Falsify or forge a power of attorney or declaration resulting in '
        'direct care changes\n\n'
        'Agents who willfully fail to comply with their obligations may be '
        'removed and sued for actual damages.',
  ),
  EducationSection(
    id: 'supp_immunity',
    category: EducationCategory.supplementary,
    title: 'Provider Immunity Protections',
    content:
        'Under 20 Pa.C.S. §5805, providers acting in good faith are '
        'protected from criminal liability, civil liability, and '
        'professional discipline for:\n'
        '• Complying with agent direction believed to be authorized\n'
        '• Refusing compliance based on good faith belief the agent lacks '
        'authority\n'
        '• Complying assuming valid execution and no amendment or revocation\n'
        '• Disclosing information believed authorized by the chapter\n'
        '• Refusing compliance due to contractual, network, or payment '
        'policy conflicts\n'
        '• Refusing compliance that conflicts with accepted clinical or '
        'medical standards\n'
        '• Making capacity determinations that trigger a directive\n'
        '• Failing to determine a patient lacks capacity\n\n'
        'Mental health care agents acting in good faith receive parallel '
        'protection.',
  ),
  EducationSection(
    id: 'supp_conflicting',
    category: EducationCategory.supplementary,
    title: 'When Directives Conflict',
    content:
        'Under 20 Pa.C.S. §5844, if you have executed multiple declarations '
        'or powers of attorney, the one with the latest execution date '
        'prevails.\n\n'
        'Important: A mental health power of attorney ALWAYS prevails over a '
        'general power of attorney, regardless of which was executed more '
        'recently.',
  ),
  EducationSection(
    id: 'supp_interstate',
    category: EducationCategory.supplementary,
    title: 'Interstate Validity',
    content:
        'Under 20 Pa.C.S. §5845, a mental health power of attorney executed '
        'in another state or jurisdiction is valid in Pennsylvania if it '
        'conforms to the laws of that jurisdiction — as long as it does not '
        'permit decisions inconsistent with Pennsylvania law. (An out-of-state '
        'directive will not be honored if an agent\'s decisions would conflict '
        'with Pennsylvania law.)\n\n'
        'However, your Pennsylvania directive may not be automatically honored '
        'in other states. Each state has its own laws governing mental health '
        'advance directives.\n\n'
        'If you travel frequently or live part-time in another state, '
        'consider:\n'
        '• Having your directive notarized (not required by PA law, but may '
        'help with out-of-state acceptance)\n'
        '• Creating a directive in each state where you receive care\n'
        '• Carrying a copy of your directive when traveling',
  ),
  EducationSection(
    id: 'supp_court_petition',
    category: EducationCategory.supplementary,
    title: 'Court Petition for Irreparable Harm',
    content:
        'Under 20 Pa.C.S. §5843, if an interested party believes that '
        'complying with your directive could cause you potential irreparable '
        'harm or death, they may petition the orphan\'s court.\n\n'
        'The court may invalidate specific provisions of your directive or '
        'authorize alternative treatment. The court must act within 72 hours '
        'of the petition being filed.',
  ),
  EducationSection(
    id: 'supp_guardian_hierarchy',
    category: EducationCategory.supplementary,
    title: 'Guardian vs. Your Directive and Agent',
    content:
        'Your directive is built to protect your autonomy even if a guardian '
        'is later appointed for you. Two sections of Act 194 work together '
        'here.\n\n'
        '**Precedence (20 Pa.C.S. §5833).** A valid MHAD takes precedence '
        'over a court-appointed guardian\'s decisions about your mental health '
        'care — your written wishes come first. A guardian can override your '
        'directive only if a court specifically authorizes it; without a court '
        'order, the guardian must follow it. If there is a conflict between '
        'your directive and what a guardian wants, your directive controls '
        'unless a court rules otherwise. This protection exists because the '
        'directive represents choices you made while you had capacity, and '
        'Pennsylvania law respects those choices even if a guardian is '
        'appointed later.\n\n'
        '**Procedure when a guardianship is initiated (20 Pa.C.S. §5841).**\n'
        '• Your provider must notify both the court and your agent about your '
        'advance directive\n'
        '• Your agent must inform the court of the directive\'s contents\n'
        '• If you are later adjudicated incapacitated, your mental health POA '
        'remains effective\n'
        '• The court SHALL PREFER allowing your agent to continue making '
        'decisions per the directive — unless you specified that a guardian '
        'has power to terminate, revoke, or suspend it\n'
        '• If the court grants a guardian mental health care powers, the '
        'guardian is bound by the same obligations as an agent\n\n'
        '**Nominating a guardian.** You may nominate a guardian of your person '
        'in your directive. The court shall appoint the person you nominate '
        'unless there is good cause or a disqualification.\n\n'
        'The practical takeaway: creating a directive now provides lasting '
        'protection for your treatment preferences, regardless of what '
        'happens in the future.',
  ),
  EducationSection(
    id: 'supp_agent_limits',
    category: EducationCategory.supplementary,
    title: 'Absolute Limits on Agent Authority',
    content:
        'Regardless of what your directive says, Pennsylvania law imposes '
        'these absolute prohibitions on your agent:\n\n'
        '• Your agent can NEVER consent to psychosurgery on your behalf\n'
        '• Your agent can NEVER consent to termination of your parental '
        'rights\n'
        '• Your agent can ONLY consent to electroconvulsive therapy (ECT) '
        'if you SPECIFICALLY authorized it in the directive\n'
        '• Your agent can ONLY consent to experimental procedures or '
        'research if you SPECIFICALLY authorized it in the directive\n\n'
        'These limits apply even if you attempt to grant broader authority '
        'in your power of attorney.\n\n'
        'Why these limits exist: The Pennsylvania legislature recognized that '
        'certain medical decisions are so serious and irreversible that they '
        'require your own informed consent, not a substitute\'s. '
        'Psychosurgery permanently alters brain tissue, and parental rights '
        'termination has lifelong consequences. ECT and experimental '
        'treatments carry significant risks that warrant explicit personal '
        'authorization rather than delegated authority.',
  ),
  EducationSection(
    id: 'supp_incapacity_declaration',
    category: EducationCategory.supplementary,
    title: 'Declaration of Incapacity (§5811)',
    content:
        'Under 20 Pa.C.S. §5811, a declaration of incapacity requires '
        'evaluation by two qualified professionals:\n\n'
        '1. A psychiatrist must be one of the evaluating professionals\n'
        '2. The second evaluator may be: another psychiatrist, a licensed '
        'psychologist, your family physician, your attending physician, or '
        'another mental health treatment professional\n\n'
        'Both evaluators must agree that you lack capacity before your '
        'directive becomes operative. You are presumed to have capacity '
        'unless a proper declaration of incapacity has been made.\n\n'
        'The declaration of incapacity must be documented in your medical '
        'records. Once capacity is restored (as certified by the same '
        'types of professionals), the directive ceases to be operative, '
        'though it remains valid for future use until it expires or is '
        'revoked.',
  ),
  EducationSection(
    id: 'supp_resources',
    category: EducationCategory.supplementary,
    title: 'External Resources: NAMI, SAMHSA & More',
    content:
        'The following organizations provide valuable support, education, '
        'and advocacy related to mental health advance directives and '
        'mental health care in Pennsylvania.\n\n'
        '\u2022 NAMI Pennsylvania (https://namipa.org)\n'
        'The National Alliance on Mental Illness — Pennsylvania chapter '
        'offers statewide advocacy, peer-led support groups, and '
        'educational programs for individuals and families affected by '
        'mental illness.\n\n'
        '\u2022 SAMHSA\'s Psychiatric Advance Directive Resources '
        '(https://www.samhsa.gov/mental-health/mental-health-treatment/advance-directives)\n'
        'The Substance Abuse and Mental Health Services Administration '
        'provides federal guidance, research, and resources on psychiatric '
        'advance directives, including best practices and implementation '
        'guides.\n\n'
        '\u2022 NRC-PAD — National Resource Center on Psychiatric Advance '
        'Directives (https://nrc-pad.org)\n'
        'A research and education center offering templates, state-specific '
        'legal information, training materials, and the latest research on '
        'psychiatric advance directives.\n\n'
        '\u2022 Disability Rights Pennsylvania '
        '(https://www.disabilityrightspa.org)\n'
        'The federally designated protection and advocacy organization for '
        'Pennsylvania, providing free legal advocacy and rights protection '
        'for people with disabilities, including mental health conditions.\n\n'
        '\u2022 Pennsylvania 211 (Dial 211)\n'
        'A free, confidential service that connects Pennsylvania residents '
        'to local mental health services, crisis support, housing, and '
        'other community resources. Available 24/7 by dialing 211.',
  ),
  EducationSection(
    id: 'supp_chapter_54_vs_58',
    category: EducationCategory.supplementary,
    title:
        'How Chapter 54 (general health care) and Chapter 58 (mental '
        'health) work together',
    content:
        'Pennsylvania law splits advance directives into two parallel '
        'chapters of Title 20 of the Consolidated Statutes:\n\n'
        '**Chapter 54 \u2014 Health Care (Act 169 of 2006).** Living wills, '
        'health-care powers of attorney, end-of-life and life-preserving '
        'treatment, the default "health-care representative" hierarchy '
        'when no agent is named. Provider-duty section: \u00a75462. Core '
        '"shall comply" sentence at \u00a75462(c)(1): "In every other case, '
        'subject to any limitation specified in the health care power of '
        'attorney, an attending physician or health care provider shall '
        'comply with a health care decision made by a health care agent '
        'or health care representative to the same extent as if the '
        'decision had been made by the principal."\n\n'
        '**Chapter 58 \u2014 Mental Health Care (Act 194 of 2004).** Mental '
        'health declarations, mental health powers of attorney, '
        'mental-health treatment decisions (medications, ECT, '
        'experimental studies, drug trials, facility preferences). '
        'Provider-duty section: \u00a75842. The "shall comply" rule for '
        'mental-health agents mirrors \u00a75462(c)(1): "An attending '
        'physician or mental health care provider shall comply with a '
        'mental health care decision made by a mental health care '
        'agent."\n\n'
        '**When does each apply?**\n'
        '\u2022 A psychiatric admission decision \u2192 Chapter 58.\n'
        '\u2022 A do-not-resuscitate question during medical care \u2192 '
        'Chapter 54.\n'
        '\u2022 A psychotropic-medication decision during a psychiatric '
        'hospitalization \u2192 Chapter 58.\n'
        '\u2022 A surgical-consent decision while you are involuntarily '
        'committed \u2192 typically Chapter 54 (general health care), but '
        'check whether your MHAD covers the specific facet.\n'
        '\u2022 A facility preference for psychiatric care \u2192 Chapter 58.\n\n'
        '**Same person, two roles.** Most people benefit from having '
        'both a Chapter 58 MHAD (which this app generates) and a '
        'Chapter 54 health-care POA. The same trusted person can be '
        'named in both roles \u2014 and often it is simplest if they are.\n\n'
        '**Why the distinction matters in a dispute.** If a hospital '
        'cites Chapter 54 rules in a mental-health situation (or vice '
        'versa), the analysis may produce the wrong answer. The '
        '"shall comply" duty exists in both chapters, but the carve-outs '
        'and decision categories differ. Knowing the correct statute '
        'helps you, your agent, and any patient advocate insist on the '
        'right framework.',
  ),
];

// ---------------------------------------------------------------------------
// USER CHECKLIST — Practical guidance not in the PDF booklet
// ---------------------------------------------------------------------------

const _checklist = [
  EducationSection(
    id: 'check_distribution',
    category: EducationCategory.checklist,
    title: 'Distribution Checklist',
    content:
        'After executing your directive, distribute copies to:\n\n'
        '• Your designated agent\n'
        '• Your alternate agent\n'
        '• Your attending physician or psychiatrist\n'
        '• Your therapist or counselor\n'
        '• Your local hospital (they often file for future admissions)\n'
        '• Family members you want informed\n'
        '• Close friends in your support network\n'
        '• Clergy or spiritual advisor (if applicable)\n'
        '• Your attorney (if you have one)\n'
        '• Keep one copy with your important papers\n\n'
        'The more people who have copies, the more likely your directive '
        'will be found and followed when needed.',
  ),
  EducationSection(
    id: 'check_storage',
    category: EducationCategory.checklist,
    title: 'Where to Store Your Directive',
    content:
        '• Keep the original in a safe but EASY TO FIND place — let others '
        'know where it is\n'
        '• Do NOT put it in a safety deposit box (inaccessible in '
        'emergencies)\n'
        '• Consider scanning and using a secure online storage service so '
        'it is available from anywhere\n'
        '• Make MANY copies — more is better than fewer\n'
        '• Tell your agent and alternate agent exactly where the original '
        'is stored',
  ),
  EducationSection(
    id: 'check_capacity_letter',
    category: EducationCategory.checklist,
    title: 'Protecting Against Capacity Challenges',
    content:
        'If you want extra protection against future challenges to your '
        'directive, consider including a letter from your treating doctor '
        'from the SAME TIME PERIOD in which you executed your directive, '
        'stating that you had capacity at that time.\n\n'
        'This is optional but strongly recommended. A contemporaneous '
        'capacity letter can help prevent challenges to the validity of '
        'your directive.',
  ),
  EducationSection(
    id: 'check_discussion',
    category: EducationCategory.checklist,
    title: 'Discussing Your Directive',
    content:
        'Before signing your directive, discuss your treatment preferences '
        'with:\n\n'
        '• Your agent — make sure they understand what you would want in '
        'various scenarios\n'
        '• Your attending physician — ensure your preferences are medically '
        'clear and understood\n'
        '• Family members — so they know your wishes and can support '
        'your agent\n\n'
        'These conversations help ensure that your directive will be '
        'interpreted and followed as you intend.',
  ),
  EducationSection(
    id: 'check_renewal',
    category: EducationCategory.checklist,
    title: 'Planning for Renewal',
    content:
        'Your directive automatically expires two years from the execution '
        'date (unless it is invoked at the time of expiration, in which case '
        'it remains effective until incapacity ends).\n\n'
        '• Mark your calendar for two years from your execution date\n'
        '• Plan to review and re-execute before expiration\n'
        '• This app will send notification reminders at 60 days and 14 days '
        'before expiration\n'
        '• When renewing, consider whether your preferences or circumstances '
        'have changed',
  ),
  EducationSection(
    id: 'check_revocation',
    category: EducationCategory.checklist,
    title: 'How to Revoke Your Directive',
    content:
        'You can revoke your directive at any time while you have capacity, '
        'either orally or in writing.\n\n'
        'Steps to revoke:\n'
        '• Notify ALL people who have copies of your directive\n'
        '• Notify your healthcare providers\n'
        '• If creating a new directive, the new one automatically supersedes '
        'the old one (but still notify everyone)\n\n'
        'During involuntary commitment: revocation is only possible if you '
        'are found capable after a psychiatric examination plus one '
        'additional professional evaluation.',
  ),
  EducationSection(
    id: 'check_agent_discussion_record',
    category: EducationCategory.checklist,
    title: 'Document Agent Discussions',
    content:
        'Keep a brief written record of discussions with your agent about '
        'your preferences. This can help if questions arise later.\n\n'
        '• Write down the date you discussed your directive\n'
        '• Note key topics covered (medications, hospitalization, ECT)\n'
        '• Document any specific scenarios you talked through\n'
        '• Have your agent confirm they understand your wishes\n\n'
        'This documentation is not legally required, but it strengthens '
        'the record if your directive is ever challenged or questioned.',
  ),
  EducationSection(
    id: 'check_update_contacts',
    category: EducationCategory.checklist,
    title: 'Update Emergency Contacts Annually',
    content:
        'Phone numbers and addresses change. Review your contact '
        'information periodically:\n\n'
        '• Confirm your agent\'s phone numbers are still current\n'
        '• Verify your alternate agent\'s contact information\n'
        '• Update your own address and phone if you\'ve moved\n'
        '• Ensure your healthcare providers have current copies\n'
        '• Check that family contacts listed in your directive are '
        'still accurate\n\n'
        'Set a calendar reminder to review contacts at least once a year, '
        'even before your directive\'s two-year expiration.',
  ),
  EducationSection(
    id: 'checklist_before_signing',
    category: EducationCategory.checklist,
    title: 'Before signing — final verification',
    content:
        'Walk through this list with the printed directive in hand, '
        'before any witness signs:\n\n'
        '☐ My full legal name is correct everywhere.\n'
        '☐ My date of birth and address are accurate.\n'
        '☐ The effective-condition language reflects when I want this to '
        'take effect.\n'
        '☐ My primary agent (and alternate, if any) is named correctly '
        '— with current phone numbers.\n'
        '☐ Agent authority box is filled in (which decisions can the '
        'agent make? Are experimental treatments explicitly addressed '
        'per §5805(c)(4)?).\n'
        '☐ Treatment-facility preferences and exclusions are listed by '
        'specific facility name where possible.\n'
        '☐ Medication preferences include both preferred and to-avoid '
        'lists with reasons.\n'
        '☐ ECT, experimental-studies, and drug-trial consent boxes are '
        'each marked (yes / no / agent / conditional — not blank).\n'
        '☐ Additional-instructions section covers religious, cultural, '
        'communication, comfort, contact, custody, and records '
        'preferences I care about.\n'
        '☐ Guardian nomination is filled in (or intentionally blank).\n'
        '☐ Two witnesses are present, both are 18+, and neither is my '
        'agent, my agent\'s spouse, my mental-health provider, or an '
        'employee of my treatment facility (unless related).\n'
        '☐ Pens are blue or black ballpoint ink (no pencil, no gel that '
        'smears).\n'
        '☐ All dates are written by the signer, not pre-printed.',
  ),
  EducationSection(
    id: 'checklist_conversation_with_agent',
    category: EducationCategory.checklist,
    title: 'Conversation with your designated agent',
    content:
        'A directive only works if your agent understands and is willing '
        'to act on it. Set aside an hour and walk through these together:\n\n'
        '☐ Show them the full directive (not just a summary).\n'
        '☐ Explain why you chose each medication preference (what worked, '
        'what didn\'t, what side effects matter most).\n'
        '☐ Walk through one or two past crisis episodes — what helped, '
        'what made things worse, what you wish had happened.\n'
        '☐ Identify your warning signs together so they can recognise an '
        'episode early.\n'
        '☐ Talk through the facilities you prefer and the ones you want '
        'to avoid, and why.\n'
        '☐ Confirm they know how to reach your primary care doctor, your '
        'psychiatrist, and your county MH/IDD office.\n'
        '☐ Talk about the ECT / research / drug-trial consent choices and '
        'the reasoning.\n'
        '☐ Confirm they are willing to advocate firmly for your stated '
        'wishes if a provider pushes back.\n'
        '☐ Tell them where the original signed copy and the wallet card '
        'are kept.\n'
        '☐ Ask them whether anything in the directive feels unclear or '
        'unworkable — and revise it if needed before signing.',
  ),
  EducationSection(
    id: 'checklist_share_with_providers',
    category: EducationCategory.checklist,
    title: 'What to share with your providers',
    content:
        'Distributing the directive to your treatment team is the single '
        'biggest factor in whether it is honored in a crisis. For each '
        'provider you regularly see:\n\n'
        '☐ Give them a *printed* copy of the signed directive (paper is '
        'still more reliably accessible than the EHR in many crisis '
        'settings).\n'
        '☐ Ask them to scan or upload it into your medical record under '
        '"advance directive" or "patient-supplied document."\n'
        '☐ Confirm it shows up in their system on your next routine '
        'visit (test by asking them to open your record).\n'
        '☐ If you change providers or facilities, give the new provider '
        'a fresh copy — directives don\'t auto-transfer.\n\n'
        'Recommended people to give a copy to:\n\n'
        '• Primary care physician.\n'
        '• Psychiatrist / mental-health prescriber.\n'
        '• Therapist or counselor.\n'
        '• Your designated agent (and alternate).\n'
        '• Your county MH/IDD office, if you receive county services.\n'
        '• A trusted family member.\n'
        '• The local emergency department you would most likely be '
        'brought to in a crisis (their advance-directive registry).',
  ),
  EducationSection(
    id: 'checklist_provider_refuses_to_follow',
    category: EducationCategory.checklist,
    title: 'If a provider refuses to follow your directive — step by step',
    content:
        'Pennsylvania law (20 Pa.C.S. §5842 for MHADs; §5462(c)(1) for '
        'general health-care directives) requires providers to "shall '
        'comply" with a valid agent\'s decisions. If a provider tells '
        'you or your agent they will not follow the directive, work '
        'through this checklist:\n\n'
        '☐ **Stay calm and document.** Note the date, time, who said '
        'what, and any witnesses. Keep it factual.\n\n'
        '☐ **Ask them to identify the specific exception they are '
        'relying on.** The only statutory exceptions are:\n'
        '   • Good-faith conscience objection;\n'
        '   • Treatment against accepted clinical practice or medical '
        'standards;\n'
        '   • Treatment physically unavailable at the facility;\n'
        '   • Institutional / insurance policy precluding compliance.\n'
        '   "I just don\'t think we should do that" is not a valid '
        'exception.\n\n'
        '☐ **Cite the statute by section.** For mental-health '
        'decisions: "Under 20 Pa.C.S. §5842, you are required to '
        'comply with my agent\'s decisions to the same extent as if I '
        'had made them." For general health-care decisions: cite '
        '§5462(c)(1).\n\n'
        '☐ **Request the §5804 transfer plan.** If they are invoking a '
        'real exception, the law requires them to (a) tell you and '
        'your agent, (b) document the reason, (c) make a reasonable '
        'effort to transfer you to a complying provider, and (d) keep '
        'treating you per the directive while the transfer is pending. '
        'Ask: "Who is taking the transfer, and what is the timeline?"\n\n'
        '☐ **Escalate within the institution.** Ask for the '
        'patient-advocate / ombudsperson, the medical-director on '
        'call, or the ethics committee. Many disputes resolve when '
        'someone with authority reviews the statute.\n\n'
        '☐ **Call Disability Rights Pennsylvania at 1-800-692-7443.** '
        'They are the federally designated protection-and-advocacy '
        'organization for PA and handle Act 194 complaints. They can '
        'advise in real time.\n\n'
        '☐ **Do not sign anything that purports to revoke the '
        'directive** unless you (the principal, with capacity) actually '
        'intend to revoke it. An agent does not have authority to '
        'revoke the principal\'s directive.\n\n'
        '☐ **Keep treating your agent as the decision-maker.** The '
        'agent should continue making decisions and asserting the '
        'statutory duty until transfer or resolution. Section 5805 '
        'protects providers who comply in good faith — there is no '
        'liability risk to following the directive.',
  ),
];

// ---------------------------------------------------------------------------
// Combined list of all sections
// ---------------------------------------------------------------------------

const allEducationSections = [
  ..._introduction,
  ..._faq,
  ..._combined,
  ..._declaration,
  ..._poa,
  ..._glossary,
  ..._supplementary,
  ..._checklist,
];

/// Map from wizard step ID strings to relevant education section IDs.
/// Used by wizard step Help buttons to filter to relevant content.
const wizardStepEducationMap = <String, List<String>>{
  'personalInfo': ['faq_valid', 'faq_what_is', 'intro_overview'],
  'effectiveCondition': [
    'combined_effective',
    'decl_effective',
    'poa_effective',
    'faq_effective',
  ],
  'treatmentFacility': [
    'combined_facility',
    'decl_facility',
    'poa_facility',
    'faq_providers_follow',
  ],
  'medications': [
    'combined_medications',
    'decl_medications',
    'poa_medications',
    'faq_what_to_include',
  ],
  'ect': [
    'combined_ect',
    'decl_ect',
    'poa_ect',
    'gloss_mhad',
  ],
  'experimentalStudies': [
    'combined_experimental',
    'decl_experimental',
    'poa_experimental',
  ],
  'drugTrials': [
    'combined_drug_trials',
    'decl_drug_trials',
    'poa_drug_trials',
  ],
  'additionalInstructions': [
    'combined_additional',
    'decl_additional',
    'poa_facility',
    'faq_what_to_include',
    'faq_deescalation',
    'faq_reproductive_health',
  ],
  'agentDesignation': [
    'combined_agent',
    'poa_agent',
    'faq_combined',
    'faq_agent_unavailable',
    'gloss_agent',
  ],
  'alternateAgent': [
    'combined_alt_agent',
    'poa_alt_agent',
    'faq_agent_unavailable',
    'gloss_agent',
  ],
  'agentAuthority': [
    'combined_authority',
    'poa_authority',
    'combined_ect',
    'combined_experimental',
    'combined_drug_trials',
  ],
  'guardianNomination': [
    'combined_guardian',
    'decl_guardian',
    'poa_guardian',
    'faq_guardian',
    'gloss_declaration',
  ],
  'review': ['faq_who_to_give', 'faq_revoke'],
  'execution': [
    'combined_execution',
    'decl_execution',
    'poa_execution',
    'faq_valid',
    'faq_finding_witnesses',
    'faq_revoke',
    'gloss_execute',
    'supp_governing_law',
  ],
};

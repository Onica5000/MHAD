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
    title: 'What is a Combined Mental Health Declaration and Power of Attorney?',
    content:
        '**In simple terms: It lets you write down your wishes AND pick '
        'someone to make decisions for you.**\n\n'
        'Pennsylvania\'s law allows you to make a combined Mental Health '
        'Declaration and Power of Attorney. This lets you make decisions about '
        'some things, but also lets you give an agent power to make other '
        'decisions for you. You choose the decisions that you want your agent '
        'to make for you, as many or as few as you like. This makes your Mental '
        'Health Advance Directive more flexible in dealing with future '
        'situations, such as new treatment options, that you would have no way '
        'of knowing about now.\n\n'
        'Your agent should be someone you trust, and you should be sure to '
        'discuss with your agent your feelings about different treatment choices '
        'so that your agent can make decisions that will be most like the ones '
        'you would have made for yourself.',
  ),
  EducationSection(
    id: 'faq_declaration',
    category: EducationCategory.faq,
    title: 'What is a Declaration?',
    content:
        '**In simple terms: It\'s a written list of instructions you give '
        'to your doctors about your care.**\n\n'
        'A Declaration contains instructions to doctors, hospitals, and other '
        'mental health care providers about your treatment in the event that '
        'you become unable to communicate your wishes. A Declaration usually '
        'deals with specific situations and does not allow much flexibility for '
        'changes that come up after the document is written, such as a new type '
        'of medical crisis, new kinds of medication, or different treatment '
        'choices.',
  ),
  EducationSection(
    id: 'faq_poa',
    category: EducationCategory.faq,
    title: 'What is a Mental Health Power of Attorney?',
    content:
        '**In simple terms: It lets you choose a trusted person to make '
        'mental health decisions for you during a crisis.**\n\n'
        'A Mental Health Power of Attorney allows you to designate someone '
        'else, called an agent, to make treatment decisions for you in the '
        'event of a mental health crisis. A Mental Health Power of Attorney '
        'provides flexibility to deal with a situation as it occurs rather than '
        'attempting to anticipate every possible situation in advance.',
  ),
  EducationSection(
    id: 'faq_valid',
    category: EducationCategory.faq,
    title: 'What makes a Mental Health Care Advance Directive valid?',
    content:
        '**In simple terms: You must be 18 or older, sign it, and have two '
        'adult witnesses.**\n\n'
        'There is no specific form that must be used, but your Mental Health '
        'Advance Directive must meet the following requirements:\n\n'
        '1. You must be at least 18 years of age.\n\n'
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
    title: 'What is Capacity?',
    content:
        'Capacity is the basic ability to understand your diagnosis and to '
        'understand the risks, benefits, and alternative treatments of your '
        'mental health care. It also includes the ability to understand what '
        'may happen if you do not receive treatment.',
  ),
  EducationSection(
    id: 'faq_capacity_proof',
    category: EducationCategory.faq,
    title: 'Do I need to include proof of my capacity with the document?',
    content:
        'No, unless you have a guardian or are currently under an involuntary '
        'commitment, you are presumed to have capacity when you make a Mental '
        'Health Advance Directive. However, at a later time it is possible for '
        'someone to challenge whether you had capacity.\n\n'
        'If you want to be very sure that no one can challenge your Mental '
        'Health Advance Directive later, you can include a letter from your '
        'treating doctor from the same time period that you made your directive '
        'stating that you had capacity at that time.',
  ),
  EducationSection(
    id: 'faq_effective',
    category: EducationCategory.faq,
    title: 'When would my Mental Health Advance Directive take effect?',
    content:
        'You can write in your Mental Health Advance Directive when you want '
        'the directive to take effect — for example, when involuntary '
        'commitment occurs, or when a psychiatrist and another mental health '
        'treatment professional states you no longer have capacity to make '
        'mental health treatment decisions.',
  ),
  EducationSection(
    id: 'faq_incapacity_determination',
    category: EducationCategory.faq,
    title: 'Who will determine that I don\'t have capacity?',
    content:
        'For the purpose of your Mental Health Advance Directive, incapacity '
        'will be determined after you are examined by a psychiatrist and one of '
        'the following: another psychiatrist, psychologist, family physician, '
        'attending physician, or mental health treatment professional. Whenever '
        'possible, one of the decision makers will be one of your current '
        'treating professionals.',
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
        'in your Advance Directive.',
  ),
  EducationSection(
    id: 'faq_changes',
    category: EducationCategory.faq,
    title: 'May I make changes to my Mental Health Advance Directive?',
    content:
        'You may change your Mental Health Advance Directive in writing at any '
        'time, as long as you have capacity. If you make significant changes, '
        'you should make a new document so that there are no conflicts or '
        'misunderstandings. Remember that your changes or a new directive must '
        'be witnessed by two individuals, at least 18 years of age, and you '
        'should give new copies to your provider, agent, and other support '
        'people.',
  ),
  EducationSection(
    id: 'faq_providers_follow',
    category: EducationCategory.faq,
    title: 'Do health care providers have to follow my instructions?',
    content:
        'Yes, unless a provider cannot in good conscience comply with your '
        'instructions because they are against accepted clinical or medical '
        'practice, or because the policies of the provider (such as what is '
        'covered by insurance) do not allow compliance, or because the '
        'treatment is physically unavailable. If the provider cannot comply for '
        'any of these reasons, the provider must tell you or your agent as soon '
        'as possible.\n\n'
        'It is very helpful to discuss your decisions with your provider when '
        'you make your Mental Health Advance Directive, so that you know '
        'whether they will be able to follow your instructions.\n\n'
        'Remember that even if you consent in advance to a particular '
        'medication or treatment, your doctor will not prescribe that treatment '
        'or drug unless it is appropriate at the time you are ill. Your consent '
        'is only good if your choices are okay at that time, within the '
        'standards of medical care. Your doctor will also have to consider if '
        'a particular treatment option is covered by your insurance.',
  ),
  EducationSection(
    id: 'faq_involuntary',
    category: EducationCategory.faq,
    title: 'How does a Mental Health Advance Directive affect involuntary commitment?',
    content:
        'The voluntary and involuntary commitment provisions of the Mental '
        'Health Procedures Act are not affected by having a Mental Health Care '
        'Advance Directive. What may be affected is how you can be treated '
        'after you are committed.',
  ),
  EducationSection(
    id: 'faq_revoke',
    category: EducationCategory.faq,
    title: 'May I revoke my Mental Health Advance Directive?',
    content:
        'You may revoke, or in other words cancel, a part or the whole Mental '
        'Health Advance Directive at any time, as long as you have capacity. '
        'This may be done either orally or in writing. It is effective as soon '
        'as you tell your provider.\n\n'
        'Your Advance Directive will automatically end after two years from '
        'the date you signed it unless you do not have capacity to make mental '
        'health care decisions at that time. If you do not have capacity at '
        'the time it would end, the Mental Health Advance Directive will stay '
        'in force until you regain capacity.',
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
    title: 'Who should I give my Mental Health Advance Directive to?',
    content:
        'The only way that your providers will know what your choices are is '
        'if you give them your Mental Health Advance Directive. You should also '
        'give copies to your treating physician, agent, and family members or '
        'other people that would be notified in the event of a crisis. Keep '
        'the original in a safe place, and be sure that someone who would be '
        'told of any crisis can get the original so it can be given to the '
        'attending physician.\n\n'
        'You may wish to carry a card in your wallet that states that you have '
        'a Mental Health Advance Directive, and who should be called in the '
        'event that you lack capacity to make mental health care decisions. '
        'Include that person\'s phone numbers, and also name another person in '
        'case the first person is not available.\n\n'
        'Remember that if you make changes or create a new Mental Health '
        'Advance Directive you must be sure that everyone has copies of the '
        'most recent version.',
  ),
  EducationSection(
    id: 'faq_out_of_state',
    category: EducationCategory.faq,
    title: 'Will my PA directive be recognized in another state?',
    content:
        'Pennsylvania law (20 Pa.C.S. §5845) provides that a mental health '
        'advance directive executed in another state is valid in PA if it was '
        'valid where executed. However, there is no guarantee that other '
        'states will recognize a Pennsylvania directive. If you travel or '
        'receive treatment in another state, check that state\'s laws or '
        'consult an attorney. Carrying your directive with you is always '
        'recommended.',
  ),
  EducationSection(
    id: 'faq_provider_refuses',
    category: EducationCategory.faq,
    title: 'What if a provider refuses to follow my directive?',
    content:
        'Under PA Act 194, a provider who is unwilling or unable to comply '
        'with your directive must make a reasonable effort to transfer your '
        'care to a provider who will comply. A provider may override your '
        'directive ONLY in limited circumstances — for example, if a court '
        'order exists, or if the treatment you requested is not available at '
        'the facility. If you believe your directive is being ignored, '
        'contact PA Protection & Advocacy at 1-800-692-7443.',
  ),
  EducationSection(
    id: 'faq_capacity_disagreement',
    category: EducationCategory.faq,
    title: 'What if the doctors disagree about my capacity?',
    content:
        'Under PA Act 194, incapacity must be determined by a psychiatrist '
        'and one additional qualified professional. If the two professionals '
        'disagree about whether you lack capacity, the directive does NOT '
        'become operative — you are presumed to have capacity unless both '
        'evaluators agree. You or your agent may request additional '
        'evaluations if you believe the determination is incorrect.',
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
    id: 'gloss_poa',
    category: EducationCategory.glossary,
    title: 'Power of Attorney',
    content:
        'A writing made by a person naming someone else to make mental health '
        'care decisions on behalf of the person.',
  ),
  EducationSection(
    id: 'gloss_revoke',
    category: EducationCategory.glossary,
    title: 'Revoke',
    content: 'To cancel or end.',
  ),
  EducationSection(
    id: 'gloss_incapacity',
    category: EducationCategory.glossary,
    title: 'Incapacity',
    content:
        'A clinical determination that a person lacks sufficient understanding '
        'or ability to make or communicate responsible decisions about mental '
        'health treatment. Under PA Act 194, incapacity is determined by a '
        'psychiatrist and one additional qualified professional (another '
        'psychiatrist, licensed psychologist, family physician, attending '
        'physician, or mental health treatment professional).',
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
    title: 'Provider Obligations Under Act 194',
    content:
        'Under 20 Pa.C.S. §5804, §5807, and §5842, attending physicians and '
        'mental health care providers MUST comply with your declaration and '
        'power of attorney instructions.\n\n'
        'If a provider objects on conscience grounds or the requested treatment '
        'is unavailable, the provider must:\n'
        '• Immediately inform you (if competent), the substitute named in your '
        'declaration, your guardian, or your agent\n'
        '• Document the reasons for noncompliance\n'
        '• Make a reasonable effort to transfer you to a compliant provider\n'
        '• Continue treating you per the directive during a pending transfer\n'
        '• Allow discharge if no compliant provider accepts the transfer\n\n'
        'Providers must also inquire about the existence of a directive at '
        'intake or initial assessment, and must inform discharged patients '
        'about the availability of declarations and powers of attorney. A '
        'provider may not require a directive as a condition of treatment, nor '
        'base treatment acceptance or refusal on whether a directive exists.',
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
        'before overriding your directive.',
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
    title: 'When an Agent Can Be Removed',
    content:
        'Under 20 Pa.C.S. §5837, an agent may be removed for any of the '
        'following reasons:\n'
        '• Death or incapacity of the agent\n'
        '• Noncompliance with the power of attorney\n'
        '• Physical assault or threats against you (the principal)\n'
        '• Coercion of you\n'
        '• Voluntary withdrawal — the agent must notify you, and if the POA '
        'is in effect, must also notify your providers\n'
        '• Divorce (see "Divorce and Agent Authority")\n\n'
        'Third parties may challenge an agent\'s authority by filing a '
        'petition in orphan\'s court.',
  ),
  EducationSection(
    id: 'supp_divorce_effect',
    category: EducationCategory.supplementary,
    title: 'Divorce and Agent Authority',
    content:
        'Under 20 Pa.C.S. §5838, if you designated your spouse as your '
        'agent, that designation is AUTOMATICALLY REVOKED when either spouse '
        'files a divorce action.\n\n'
        'The only exception is if your power of attorney clearly shows your '
        'intent for the designation to continue despite a divorce filing.\n\n'
        'If your spouse is your agent and you are considering divorce, you '
        'should plan to designate a new agent.',
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
        'conforms to the laws of that jurisdiction.\n\n'
        'Exception: An out-of-state directive will not be honored if an '
        'agent\'s decisions would conflict with Pennsylvania law.',
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
    title: 'Guardian vs. Agent Authority',
    content:
        'Under 20 Pa.C.S. §5841, if a guardianship proceeding is initiated:\n'
        '• Your provider must notify both the court and your agent about '
        'your advance directive\n'
        '• Your agent must inform the court of the directive\'s contents\n'
        '• If you are later adjudicated incapacitated, your mental health '
        'POA remains effective\n'
        '• The court SHALL PREFER allowing your agent to continue making '
        'decisions per the directive\n'
        '• Exception: unless you specified that a guardian has power to '
        'terminate, revoke, or suspend the directive\n'
        '• If the court grants a guardian mental health care powers, the '
        'guardian is bound by the same obligations as an agent\n\n'
        'You may nominate a guardian of your person in your directive. The '
        'court shall appoint per your nomination unless there is good cause '
        'or disqualification.',
  ),
  EducationSection(
    id: 'supp_guardian_directive_precedence',
    category: EducationCategory.supplementary,
    title: 'Your Directive Takes Precedence Over a Guardian',
    content:
        'Under 20 Pa.C.S. §5833 (Act 194), your Mental Health Advance '
        'Directive is designed to protect your autonomy even if a guardian '
        'is later appointed for you.\n\n'
        'Key points:\n\n'
        '• A valid MHAD takes precedence over a court-appointed guardian\'s '
        'decisions regarding your mental health care. Your written wishes '
        'come first.\n\n'
        '• A guardian can only override your directive if a court '
        'specifically authorizes it. Without a court order, the guardian '
        'must follow your directive.\n\n'
        '• If there is a conflict between what your directive says and what '
        'a guardian wants, your directive controls unless a court rules '
        'otherwise.\n\n'
        '• This protection exists because the directive represents choices '
        'you made while you had capacity. Pennsylvania law respects those '
        'choices even if your circumstances change and a guardian is '
        'appointed later.\n\n'
        'This means that creating a directive now provides lasting '
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
    id: 'supp_interstate_validity',
    category: EducationCategory.supplementary,
    title: 'Interstate Validity',
    content:
        'Under PA Act 194 \u00a75845, out-of-state mental health powers of '
        'attorney are valid in Pennsylvania if they conform to their origin '
        'state\'s law, as long as they don\'t permit decisions inconsistent '
        'with Pennsylvania law.\n\n'
        'However, your Pennsylvania directive may not be automatically '
        'honored in other states. Each state has its own laws governing '
        'mental health advance directives.\n\n'
        'If you travel frequently or live part-time in another state, '
        'consider:\n'
        '\u2022 Having your directive notarized (not required by PA law, but '
        'may help with out-of-state acceptance)\n'
        '\u2022 Creating a directive in each state where you receive care\n'
        '\u2022 Carrying a copy of your directive when traveling',
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
    'faq_incapacity_determination',
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
  ],
  'agentDesignation': [
    'combined_agent',
    'poa_agent',
    'faq_poa',
    'gloss_agent',
  ],
  'alternateAgent': [
    'combined_alt_agent',
    'poa_alt_agent',
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
  'review': ['faq_who_to_give', 'faq_changes'],
  'execution': [
    'combined_execution',
    'decl_execution',
    'poa_execution',
    'faq_valid',
    'gloss_execute',
    'supp_governing_law',
  ],
};

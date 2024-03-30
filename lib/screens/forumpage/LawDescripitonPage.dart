import 'package:flutter/material.dart';

class LawDescriptionPage extends StatelessWidget {
  final String lawName;
  final String lawDescription;

  const LawDescriptionPage({
    required this.lawName,
    required this.lawDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Law Description: $lawName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About $lawName',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                lawDescription,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'For Children:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _generateChildFriendlyExplanation(lawName),
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generate child-friendly explanation for each law
  String _generateChildFriendlyExplanation(String lawName) {
    switch (lawName) {
      case 'The Juvenile Justice (Care and Protection of Children) Act, 2015':
        return """
        The Juvenile Justice Act is a law in India that is made to protect children who are below the age of 18 years. It aims to make sure that children who are in conflict with the law are treated with care and given opportunities to improve their lives. This law also focuses on providing support and rehabilitation to children who are victims of abuse, neglect, or exploitation. It helps in creating a safe environment for children where they can grow and develop to their full potential.
        """;
      case 'The Protection of Children from Sexual Offences (POCSO) Act, 2012':
        return """
        The POCSO Act is a special law in India that is made to protect children from sexual abuse and exploitation. It defines various forms of sexual offenses against children and provides strict punishment for those who commit such crimes. This law also aims to make the legal process easier for children who are victims of sexual abuse by providing special procedures for recording their statements and conducting trials. It focuses on ensuring the safety and well-being of children and creating awareness about the importance of preventing sexual offenses against them.
        """;
      case 'The Child Labour (Prohibition and Regulation) Amendment Act, 2016':
        return """
        The Child Labour Act is a law in India that aims to prohibit and regulate the employment of children in various occupations and processes. It prohibits the engagement of children in hazardous occupations and processes and regulates the working conditions of children in non-hazardous occupations. This law also provides for the rehabilitation and education of children who are rescued from child labor. It focuses on eliminating child labor and ensuring that every child has the opportunity to go to school and get an education.
        """;
      case 'The Commissions for Protection of Child Rights Act, 2005':
        return """
        The Commissions for Protection of Child Rights Act is a law in India that is made to protect the rights of children. It provides for the establishment of commissions at the national and state levels to monitor and protect the rights of children. These commissions work to ensure that children are protected from exploitation, abuse, and discrimination. They also promote the welfare and development of children by implementing various programs and policies. This law focuses on creating a safe and nurturing environment for children where they can thrive and reach their full potential.
        """;
      case 'The Prohibition of Child Marriage Act, 2006':
        return """
        The Prohibition of Child Marriage Act is a law in India that aims to prevent the marriage of children below the age of 18 years. It prohibits the solemnization of child marriages and makes it a punishable offense for those who perform, promote, or participate in such marriages. This law also provides for the annulment of child marriages and the protection and rehabilitation of child brides. It focuses on protecting the rights and well-being of children and ensuring that they have the opportunity to grow and develop in a safe and healthy environment.
        """;
      case 'The Right of Children to Free and Compulsory Education Act, 2009':
        return """
        The Right of Children to Free and Compulsory Education Act is a law in India that makes education a fundamental right for all children between the ages of 6 and 14 years. It mandates that every child has the right to free and compulsory education in a neighborhood school up to the elementary level. This law also lays down specific provisions for the admission, attendance, and completion of elementary education by all children. It focuses on ensuring equal opportunities for education and eliminating barriers to learning for children from marginalized and disadvantaged communities.
        """;
      case 'The Infant Milk Substitutes, Feeding Bottles and Infant Foods (Regulation of Production, Supply and Distribution) Act, 1992':
        return """
        The Infant Milk Substitutes, Feeding Bottles and Infant Foods Act is a law in India that regulates the production, supply, and distribution of infant milk substitutes, feeding bottles, and infant foods. It aims to promote and protect breastfeeding and ensure the safe and appropriate use of breast milk substitutes when necessary. This law prohibits the promotion and marketing of infant milk substitutes and feeding bottles and regulates the labeling and packaging of infant foods. It focuses on protecting the health and nutrition of infants and young children and promoting optimal infant feeding practices.
        """;
      case 'The Immoral Traffic (Prevention) Act, 1956':
        return """
        The Immoral Traffic Act is a law in India that is made to prevent the trafficking of women and children for the purpose of prostitution. It defines various offenses related to prostitution, such as trafficking, soliciting, and living off the earnings of prostitution. This law provides for the rescue and rehabilitation of victims of trafficking and the prosecution of traffickers and brothel owners. It focuses on protecting the dignity and rights of women and children and combating the exploitation and abuse associated with prostitution.
        """;
      case 'The Children (Pledging of Labour) Act, 1933':
        return """
        The Children Act is a law in India that prohibits the pledging of children for labor. It makes it illegal for parents or guardians to pledge their children as security for loans or advances. This law aims to protect children from exploitation and ensure that they are not subjected to bonded labor or forced labor. It focuses on safeguarding the rights and well-being of children and promoting their physical, mental, and emotional development.
        """;
      case 'The Child and Adolescent Labour (Prohibition and Regulation) Act, 1986':
        return """
        The Child and Adolescent Labour Act is a law in India that prohibits the employment of children below the age of 14 years in certain occupations and processes. It regulates the working conditions of adolescents between the ages of 14 and 18 years and prohibits their engagement in hazardous occupations and processes. This law also provides for the rehabilitation and education of children and adolescents who are rescued from child labor. It focuses on eliminating child labor and ensuring that every child has the opportunity to go to school and get an education.
        """;
      case 'The Factories Act, 1948 (Section 67 and 68)':
        return """
        The Factories Act is a law in India that regulates the working conditions in factories. Sections 67 and 68 of the Act specifically deal with the employment of children in factories. Section 67 prohibits the employment of children below the age of 14 years in any factory, while Section 68 prohibits the employment of adolescents between the ages of 15 and 18 years in hazardous processes. These provisions aim to protect children from exploitation and ensure their safety and well-being in the workplace.
        """;
      case 'The Mines Act, 1952 (Sections 22 and 24)':
        return """
        The Mines Act is a law in India that regulates the working conditions in mines. Sections 22 and 24 of the Act specifically deal with the employment of children in mines. Section 22 prohibits the employment of children below the age of 18 years in any mine, while Section 24 prohibits the employment of adolescents between the ages of 15 and 18 years in hazardous processes. These provisions aim to protect children from exploitation and ensure their safety and well-being in the workplace.
        """;
      case 'The Beedi and Cigar Workers (Conditions of Employment) Act, 1966':
        return """
        The Beedi and Cigar Workers Act is a law in India that regulates the working conditions of workers in beedi and cigar establishments. It prohibits the employment of children below the age of 14 years in any beedi or cigar establishment and regulates the working conditions of adolescents between the ages of 14 and 18 years. This law aims to protect children from exploitation and ensure their safety and well-being in the workplace.
        """;
      case 'The Bonded Labour System (Abolition) Act, 1976':
        return """
        The Bonded Labour System Act is a law in India that abolishes the bonded labor system and prohibits all forms of bonded labor. It defines bonded labor as a system of forced or bonded labor where a person is compelled to work in order to repay a debt or loan. This law aims to eradicate bonded labor and provide rehabilitation and relief to bonded laborers. It focuses on protecting the rights and dignity of workers and ensuring their freedom from exploitation and coercion.
        """;
      case 'The Child Labour (Prohibition and Regulation) Act, 1986':
        return """
        The Child Labour Act is a law in India that prohibits the employment of children below the age of 14 years in certain occupations and processes. It regulates the working conditions of adolescents between the ages of 14 and 18 years and prohibits their engagement in hazardous occupations and processes. This law also provides for the rehabilitation and education of children and adolescents who are rescued from child labor. It focuses on eliminating child labor and ensuring that every child has the opportunity to go to school and get an education.
        """;
      default:
        return '123';
    }
  }
}

import 'package:flutter/material.dart';
import 'LawDescripitonPage.dart';

class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Safety Laws Forum'),
      ),
      body: ListView.builder(
        itemCount: _childSafetyLaws.length,
        itemBuilder: (context, index) {
          return GestureDetector( // Wrap each ForumPost with GestureDetector
            onTap: () {
              // Navigate to LawDescriptionPage when a law is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LawDescriptionPage(
                    lawName: _childSafetyLaws[index], // Pass the law name to LawDescriptionPage
                    lawDescription: _generateLawDescription(_childSafetyLaws[index]), // Pass the law description to LawDescriptionPage
                  ),
                ),
              );
            },
            child: ForumPost(
              title: _childSafetyLaws[index],
              author: 'Ministry of Women and Child Development',
              date: 'February 18, 2024',
              content: _generateShortDescription(_childSafetyLaws[index]),
              likes: 10 + index, // Placeholder values for likes and comments
              comments: 5 + index,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality to create new forum posts
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Generate a short description for the forum post
  String _generateShortDescription(String lawName) {
    switch (lawName) {
      case 'The Juvenile Justice (Care and Protection of Children) Act, 2015':
        return 'A law made to protect children below the age of 18 years.';
      case 'The Protection of Children from Sexual Offences (POCSO) Act, 2012':
        return 'A special law to protect children from sexual abuse and exploitation.';
      case 'The Child Labour (Prohibition and Regulation) Amendment Act, 2016':
        return 'A law to prohibit and regulate child labor.';
      case 'The Commissions for Protection of Child Rights Act, 2005':
        return 'A law to establish commissions for the protection of child rights.';
      case 'The Prohibition of Child Marriage Act, 2006':
        return 'A law to prohibit the solemnization of child marriages.';
      case 'The Right of Children to Free and Compulsory Education Act, 2009':
        return 'A law to provide free and compulsory education to all children.';
      case 'The Infant Milk Substitutes, Feeding Bottles and Infant Foods (Regulation of Production, Supply and Distribution) Act, 1992':
        return 'A law to regulate the production and distribution of infant milk substitutes.';
      case 'The Immoral Traffic (Prevention) Act, 1956':
        return 'A law to prevent immoral trafficking of persons, including children.';
      case 'The Children (Pledging of Labour) Act, 1933':
        return 'A law to prohibit the pledging of labor by children.';
      case 'The Child and Adolescent Labour (Prohibition and Regulation) Act, 1986':
        return 'A law to prohibit the employment of children in certain occupations and regulate the conditions of work of children.';
      case 'The Factories Act, 1948 (Section 67 and 68)':
        return 'A law to regulate the working conditions in factories, including provisions for the employment of children.';
      case 'The Mines Act, 1952 (Sections 22 and 24)':
        return 'A law to regulate the conditions of work and safety in mines, including provisions for the employment of children.';
      case 'The Beedi and Cigar Workers (Conditions of Employment) Act, 1966':
        return 'A law to regulate the conditions of employment in beedi and cigar establishments, including provisions for the employment of children.';
      case 'The Bonded Labour System (Abolition) Act, 1976':
        return 'A law to abolish the bonded labor system, including provisions for the rehabilitation of bonded laborers and their families.';
      case 'The Child Labour (Prohibition and Regulation) Act, 1986':
        return 'A law to prohibit the employment of children in certain occupations and regulate the conditions of work of children.';
      default:
        return '123';
    }
  }


  // Generate law description for LawDescriptionPage
  String _generateLawDescription(String lawName) {
    // Implement law descriptions for all 15 laws
    // Return a placeholder description for now
    return 'Law description for $lawName';
  }
}

class ForumPost extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String content;
  final int likes;
  final int comments;

  const ForumPost({
    required this.title,
    required this.author,
    required this.date,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2, // Adjusted to fit the screen
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            Text(
              '$author on $date',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            Text(
              content,
              maxLines: 5, // Adjusted to fit the screen
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.thumb_up),
                Text('$likes'),
                SizedBox(width: 8.0),
                Icon(Icons.comment),
                Text('$comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// List of Indian laws related to child safety
List<String> _childSafetyLaws = [
  "The Juvenile Justice (Care and Protection of Children) Act, 2015",
  "The Protection of Children from Sexual Offences (POCSO) Act, 2012",
  "The Child Labour (Prohibition and Regulation) Amendment Act, 2016",
  "The Commissions for Protection of Child Rights Act, 2005",
  "The Prohibition of Child Marriage Act, 2006",
  "The Right of Children to Free and Compulsory Education Act, 2009",
  "The Infant Milk Substitutes, Feeding Bottles and Infant Foods (Regulation of Production, Supply and Distribution) Act, 1992",
  "The Immoral Traffic (Prevention) Act, 1956",
  "The Children (Pledging of Labour) Act, 1933",
  "The Child and Adolescent Labour (Prohibition and Regulation) Act, 1986",
  "The Factories Act, 1948 (Section 67 and 68)",
  "The Mines Act, 1952 (Sections 22 and 24)",
  "The Beedi and Cigar Workers (Conditions of Employment) Act, 1966",
  "The Bonded Labour System (Abolition) Act, 1976",
  "The Child Labour (Prohibition and Regulation) Act, 1986",
];

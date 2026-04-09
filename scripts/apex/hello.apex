// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

// =============================================
// BULK TEST: Create 300 Completely New Realistic Contacts
// All names are fresh and different from previous lists
// =============================================

List<Contact> contacts = new List<Contact>();

// Completely new first names list
List<String> firstNames = new List<String>{
    'Can', 'Efe', 'Mira', 'Atlas', 'Leyla', 'Poyraz', 'Ada', 'Ege', 'Lila', 'Derin',
    'Asya', 'Rüzgar', 'Nehir', 'Kuzey', 'Deniz', 'Toprak', 'Güneş', 'Yıldız', 'Bulut', 'Yağmur',
    'Baran', 'Duru', 'Ilgın', 'Kıraç', 'Melis', 'Naz', 'Ozan', 'Pera', 'Rana', 'Sıla',
    'Tuna', 'Ulaş', 'Vera', 'Yaren', 'Zara', 'Alara', 'Beren', 'Cemre', 'Dilara', 'Ela',
    'Feride', 'Gizem', 'Hira', 'Işıl', 'Jale', 'Kaan', 'Lale', 'Mavi', 'Narin', 'Oya',
    'Pelin', 'Rüya', 'Selen', 'Tuğçe', 'Umay', 'Vildan', 'Yasmin', 'Zeyno', 'Aras', 'Batu'
};

// Completely new last names list
List<String> lastNames = new List<String>{
    'Akman', 'Balkan', 'Candan', 'Doğan', 'Ersoy', 'Fırat', 'Gökalp', 'Hancı', 'Işık', 'Karaca',
    'Lalezar', 'Mertcan', 'Nalbantoğlu', 'Özkan', 'Peker', 'Rüzgar', 'Sönmez', 'Toker', 'Uyanık', 'Vural',
    'Yalın', 'Zorlu', 'Ateşoğlu', 'Bozkurt', 'Cengiz', 'Duman', 'Erenler', 'Fidan', 'Güven', 'Hekimoğlu',
    'Irmak', 'Kılıçarslan', 'Liman', 'Mavi', 'Narin', 'Okan', 'Pazar', 'Rüzgarlı', 'Sarıoğlu', 'Toker',
    'Uyan', 'Veli', 'Yaman', 'Zengin', 'Aksoy', 'Balkan', 'Çınar', 'Denizoğlu', 'Erbay', 'Fırıncıoğlu'
};

for (Integer i = 0; i < 300; i++) {
    String firstName = firstNames[Math.mod(i, firstNames.size())];
    String lastName  = lastNames[Math.mod(i, lastNames.size())];
   
    contacts.add(new Contact(
        FirstName = firstName,
        LastName  = lastName
    ));
}

insert contacts;

System.debug('✅ Successfully inserted 300 completely new realistic Contacts. Total: ' + contacts.size());

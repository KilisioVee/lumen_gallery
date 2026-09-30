import 'dart:ui';

class Art {
  const Art(this.title, this.artist, this.medium, this.description, this.z,
      this.side, this.colors);
  final String title, artist, medium, description;
  final double z, side;
  final List<Color> colors;
}

// Fictional demo content. Replace with your real collection.
const collection = <Art>[
  Art('Quiet River', 'Amina Wekesa', 'Oil on canvas',
      'A study of water, memory and morning light.', 3.5, -1,
      [Color(0xFF163C51), Color(0xFF5197A2), Color(0xFFF0D4A1)]),
  Art('Golden Forms', 'David Otieno', 'Acrylic',
      'Geometry and colour explore sunlight across a city.', 5, 1,
      [Color(0xFF513421), Color(0xFFC79136), Color(0xFFF5DB97)]),
  Art('City Rhythm', 'Nia Kamau', 'Mixed media',
      'An abstract celebration of urban movement and connection.', 8, -1,
      [Color(0xFF322048), Color(0xFF9163BD), Color(0xFFDF8579)]),
  Art('Skyline Memory', 'Samuel Kibet', 'Watercolour',
      'A skyline suspended between rain and evening.', 10, 1,
      [Color(0xFF244E6B), Color(0xFF89B3CC), Color(0xFFE7E8DC)]),
  Art('Rooted', 'Zawadi Noor', 'Textile collage',
      'Layered earth tones evoke heritage and belonging.', 13, -1,
      [Color(0xFF59382B), Color(0xFFA87552), Color(0xFFCFB687)]),
  Art('After Rain', 'Maya Njeri', 'Digital print',
      'Light and reflection transform a landscape after rainfall.', 15, 1,
      [Color(0xFF174B53), Color(0xFF5EAAA7), Color(0xFFCFE3CD)]),
  Art('Still Morning', 'Amina Wekesa', 'Oil on canvas',
      'A quiet exploration of space and the early morning.', 18, -1,
      [Color(0xFF334C68), Color(0xFF7894AF), Color(0xFFE9C6A6)]),
  Art('Warm Horizon', 'David Otieno', 'Acrylic',
      'Warm bands of colour echo the evening horizon.', 21, 1,
      [Color(0xFF704941), Color(0xFFBE8270), Color(0xFFEBCB9A)]),
];
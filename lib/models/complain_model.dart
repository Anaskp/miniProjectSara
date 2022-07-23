class ComplaintModel {
  final String image;
  final String? caption;
  final String location;
  final String userImg;
  final String userName;
  final int vote;

  ComplaintModel({
    required this.image,
    this.caption,
    required this.location,
    required this.userImg,
    required this.userName,
    required this.vote,
  });
}

final List<ComplaintModel> data = [
  ComplaintModel(
    caption: 'Pothhole',
    image:
        'https://images.unsplash.com/photo-1560782202-154b39d57ef2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',
    location: 'Chokli',
    userImg:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',
    userName: 'Roby',
    vote: 8,
  ),
  ComplaintModel(
    image:
        'https://images.unsplash.com/photo-1587763483696-6d41d2de6084?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',
    location: 'Chungam',
    userImg:
        'https://images.unsplash.com/photo-1610276198568-eb6d0ff53e48?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=580&q=80',
    userName: 'Kamala',
    vote: 2,
  ),
  ComplaintModel(
    caption: 'Waste',
    image:
        'https://images.unsplash.com/photo-1605600659908-0ef719419d41?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=436&q=80',
    location: 'Serambi',
    userImg:
        'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
    userName: 'Madhavan',
    vote: 12,
  ),
  ComplaintModel(
    image:
        'https://images.unsplash.com/flagged/photo-1572213426852-0e4ed8f41ff6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=874&q=80',
    location: 'Kolasheri',
    userImg:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
    userName: 'Christine',
    vote: 5,
  ),
  ComplaintModel(
    image:
        'https://images.unsplash.com/photo-1629735871637-2109ebdd1dad?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
    location: 'Kadirur',
    userImg:
        'https://images.unsplash.com/photo-1552234994-66ba234fd567?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',
    userName: 'Muhammed',
    vote: 8,
  ),
  ComplaintModel(
    image:
        'https://images.unsplash.com/photo-1591020838520-d2f83a71bb10?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',
    location: 'Thalassery',
    userImg:
        'https://images.unsplash.com/photo-1586682643135-060f061868b6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=371&q=80',
    userName: 'Fathima',
    vote: 8,
  ),
];

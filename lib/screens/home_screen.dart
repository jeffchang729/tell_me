// lib/screens/home_screen.dart
// 主畫面 - 資訊流
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/feed_models.dart';
import '../models/meal_card_data.dart'; // [修改] 我們將復用這個模型來代表主題卡片
import '../widgets/feed/post_card_view.dart';
import '../widgets/feed/info_post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.animationController}) : super(key: key);
  final AnimationController? animationController;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  Animation<double>? topBarAnimation;

  // [修改] 這裡的資料現在代表 "主題資訊卡片"
  final List<MealCardData> topicCards = [
    MealCardData(
      title: '股票',
      imagePath: '', // 不再需要圖片
      calories: 0,
      items: [],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealCardData(
      title: '天氣',
      imagePath: '',
      calories: 0,
      items: [],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealCardData(
      title: '國際大事',
      imagePath: '',
      calories: 0,
      items: [],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    MealCardData(
      title: '科技',
      imagePath: '',
      calories: 0,
      items: [],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
  
  // 這是下方垂直資訊貼文的資料
  final List<PostData> posts = [
    PostData(
      userName: '智慧分析師',
      location: '台北市, 內湖區',
      cardTitle: '台積電 (2330)',
      cardSubtitle: '今日股價',
      cardGradientStart: '#738AE6',
      cardGradientEnd: '#5C5EDD',
      caption: '台積電今日開盤走高，上漲 2.5%，帶動大盤指數。',
      likesCount: 102,
      timeAgo: '15 分鐘前',
      comments: [Comment(userName: 'investor_cat', text: 'AI 趨勢無敵！')],
    ),
    PostData(
      userName: '天氣小助理',
      location: '台灣, 中央氣象署',
      cardTitle: '天氣預報',
      cardSubtitle: '台北市',
      cardGradientStart: '#FA7D82',
      cardGradientEnd: '#FFB295',
      caption: '今日天氣晴朗，高溫可達 32 度，紫外線偏高，外出請注意防曬。',
      likesCount: 88,
      timeAgo: '1 小時前',
      comments: [
        Comment(userName: 'sunny_day', text: '終於出太陽了！'),
        Comment(userName: 'beach_lover', text: '週末可以去海邊了！'),
      ],
    ),
  ];

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) setState(() => topBarOpacity = 1.0);
      } else if (scrollController.offset > 0 && scrollController.offset < 24) {
        setState(() => topBarOpacity = scrollController.offset / 24);
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) setState(() => topBarOpacity = 0.0);
      }
    });

    widget.animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: widget.animationController!,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 40 * (1.0 - widget.animationController!.value), 0.0),
                    child: child,
                  ),
                );
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 16,
                    ),
                  ),
                  // [修改] 將頂部區域的資料來源換成 topicCards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PostCardView(meals: topicCards),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Divider(height: 1, color: AppTheme.background)),
                  // 顯示垂直的資訊貼文列表
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => InfoPostCard(post: posts[index]),
                      childCount: posts.length,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 62 + MediaQuery.of(context).padding.bottom)),
                ],
              ),
            ),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey.withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'TELL ME',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: AppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, color: AppTheme.grey),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: AppTheme.grey),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

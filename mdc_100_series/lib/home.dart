import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'model/product.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortOrder = 'ASC'; // 기본 정렬 기준

  // Product 리스트를 받아서 카드 형태로 변환하는 메서드
  List<Card> _buildGridCards(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    // 선택한 정렬 기준에 따라 제품 리스트를 정렬
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) => _sortOrder == 'ASC'
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));

    return sortedProducts.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      formatter.format(product.price),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          // 상세 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(product: product),
                            ),
                          );
                        },
                        child: const Text('More'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // 정렬 기준을 업데이트하는 메서드
  void _updateSortOrder(String sortOrder) {
    setState(() {
      _sortOrder = sortOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    // AppState의 products 리스트를 Provider를 통해 가져옴
    final products = context.watch<AppState>().products;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: const Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              semanticLabel: 'cart',
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add_product',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/addproduct');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // DropdownButtonExample에서 선택한 정렬 기준을 _updateSortOrder로 전달
          Center(
            child: DropdownButtonExample(onSortOrderChanged: _updateSortOrder),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 8.0 / 9.0,
              children: _buildGridCards(context, products),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  final ValueChanged<String> onSortOrderChanged;

  const DropdownButtonExample({Key? key, required this.onSortOrderChanged})
      : super(key: key);

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

const List<String> list = <String>['ASC', 'DESC'];

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down_sharp),
      elevation: 0,
      alignment: AlignmentDirectional.centerStart,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
        // 선택한 정렬 기준을 콜백으로 전달
        widget.onSortOrderChanged(dropdownValue);
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

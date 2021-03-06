import 'package:delivery_customer/catalog/restaurant/addToBasketDialog.dart';
import 'package:delivery_customer/homePage.dart';
import 'package:delivery_customer/iocContainer.dart';
import 'package:delivery_customer/util/appTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:openapi/model/dish.dart';
import 'package:openapi/model/restaurant.dart';
import 'package:provider/provider.dart';

part 'restaurantPage.g.dart';

@swidget
Widget _deliveryDetails(BuildContext context) {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: new Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("\$0.00",
                          style: AppTextStyle.sectionHeader(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text("delivery fee", style: AppTextStyle.copy(context))
                    ])),
            Container(
                height: 28,
                width: 1,
                decoration: BoxDecoration(color: Colors.grey)),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("30 - 40",
                          style: AppTextStyle.sectionHeader(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text("minutes", style: AppTextStyle.copy(context))
                    ]))
          ]));
}

@swidget
Widget _dishItem(BuildContext context, Dish dish, Restaurant restaurant) {
  var imageUrl =
      "https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=600,format=auto,quality=50/https://cdn.doordash.com/media/photos/3fad35a0-3c37-4b26-995d-412042b7013a-retina-large.jpg";

  return InkWell(
      key: Key('DishItem'),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              maxChildSize: 0.8,

              // minChildSize: 0.25,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  color: Colors.white,
                  child: AddToBasketDialog(dish, restaurant),
                );
              },
            );
          },
        );
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(dish.name, style: AppTextStyle.sectionHeader(context)),
                  Container(height: 4),
                  Text(dish.name,
                      maxLines: 3, style: AppTextStyle.copy(context)),
                  Container(height: 4),
                  Text(dish.price.formatted,
                      style: AppTextStyle.copy(context)
                          .copyWith(color: Colors.black))
                ])),
            Container(
                height: 80,
                width: 80,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fitHeight,
                    )))
          ])));
}

@swidget
Widget _header(BuildContext context, Restaurant restaurant) {
  return Padding(
      padding: EdgeInsets.only(top: 56.0 + 8, left: 8, right: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(restaurant.name, style: AppTextStyle.header(context)),
        Text(
          "Chinese, Asian",
          style: AppTextStyle.copy(context),
        ),
        Container(height: 4),
        Row(
          children: [
            RestaurantRating(4.8),
            Container(width: 4),
            Text("(500+) • 1.2 km • \$\$", style: AppTextStyle.copy(context)),
          ],
        ),
        Container(height: 16),
        _DeliveryDetails(),
      ]));
}

@hwidget
Widget restaurantPage(BuildContext context, Restaurant restaurant) {
  var restaurantsApi = Provider.of<IocContainer>(context).restaurantsApi;
  var scrollController = useMemoized(() => ScrollController());
  var appBarVisible = useState(false);

  var dishes = useState<List<Dish>>([]);
  useEffect(() {
    restaurantsApi
        .restaurantDishes(restaurant.id)
        .then((value) => dishes.value = value.data);

    scrollController.addListener(() {
      print(scrollController.offset);
      appBarVisible.value = scrollController.offset > 150;
    });
  }, []);

  var onBackButtonPressed = () => Navigator.of(context).pop();

  return Scaffold(
    key: Key('RestaurantPage'),
    body: Container(
      color: Colors.white,
      child: Stack(children: [
        ListView.builder(
            controller: scrollController,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _Header(restaurant);
              }
              return _DishItem(
                  dishes.value[(index - 1) % dishes.value.length], restaurant);
            },
            itemCount: 1 + dishes.value.length * 3),
        Container(
            margin: EdgeInsets.only(top: 8, left: 8),
            child: RawMaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                constraints: BoxConstraints.tight(Size(40.0, 40.0)),
                fillColor: Colors.white,
                child: Icon(Icons.arrow_back),
                shape: CircleBorder(),
                onPressed: onBackButtonPressed)),
        appBarVisible.value
            ? Container(
                height: kToolbarHeight,
                child: AppBar(
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Colors.black),
                  elevation: 1,
                  centerTitle: true,
                  title: Text(
                    restaurant.name,
                    style: AppTextStyle.sectionHeader(context),
                  ),
                ))
            : Container()
      ]),
    ),
  );
}

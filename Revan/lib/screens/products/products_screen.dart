import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        CategoryModel,
        FilterAttributeModel,
        Product,
        ProductModel,
        TagModel,
        UserModel;
import '../../modules/dynamic_layout/helper/countdown_timer.dart';
import '../../modules/dynamic_layout/helper/helper.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../services/index.dart';
import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../../widgets/product/product_list.dart';
import '../common/app_bar_mixin.dart';
import 'filter_mixin/products_filter_mixin.dart';
import 'products_backdrop.dart';
import 'products_flatview.dart';
import 'products_mixin.dart';
import 'widgets/category_menu.dart';

class ProductsScreen extends StatefulWidget {
  final List<Product>? products;
  final ProductConfig? config;
  final Duration countdownDuration;
  final bool enableSearchHistory;
  final String? routeName;
  final bool autoFocusSearch;

  const ProductsScreen({
    this.products,
    this.countdownDuration = Duration.zero,
    this.config,
    this.enableSearchHistory = false,
    this.routeName,
    this.autoFocusSearch = true,
  });

  @override
  State<StatefulWidget> createState() {
    return ProductsScreenState();
  }
}

class ProductsScreenState extends State<ProductsScreen>
    with
        SingleTickerProviderStateMixin,
        AppBarMixin,
        ProductsMixin,
        ProductsFilterMixin {
  late AnimationController _controller;
  final _searchFieldController = TextEditingController();

  bool get hasAppBar => showAppBar(widget.routeName ?? RouteList.backdrop);

  ProductConfig get productConfig => widget.config ?? ProductConfig.empty();

  @override
  bool get enableSearchHistory => widget.enableSearchHistory;

  @override
  CategoryModel get categoryModel =>
      Provider.of<CategoryModel>(context, listen: false);

  @override
  TagModel get tagModel => Provider.of<TagModel>(context);

  ProductModel get productModel =>
      Provider.of<ProductModel>(context, listen: false);

  @override
  FilterAttributeModel get filterAttrModel =>
      Provider.of<FilterAttributeModel>(context, listen: false);

  UserModel get userModel => Provider.of<UserModel>(context, listen: false);

  AppModel get appModel => Provider.of<AppModel>(context, listen: false);

  /// Image ratio from Product Cart
  double get ratioProductImage => appModel.ratioProductImage;

  double get productListItemHeight => kProductDetail.productListItemHeight;

  bool get enableProductBackdrop => kAdvanceConfig.enableProductBackdrop;

  bool get showBottomCornerCart => kAdvanceConfig.showBottomCornerCart;

  List<Product>? products = [];
  String? errMsg;

  String _currentTitle = '';

  String get currentTitle =>
      search != null ? S.of(context).results : _currentTitle;

  StreamSubscription? _streamSubscription;

  bool get allowMultipleCategory =>
      ServerConfig().isWooPluginSupported || ServerConfig().isWordPress;

  bool get allowMultipleTag =>
      ServerConfig().isWooPluginSupported || ServerConfig().isWordPress;

  @override
  void initState() {
    super.initState();
    _initFilter();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    Services().firebase.firebaseAnalytics?.logViewItemList(
          itemListId: productModel.categoryIds?.join(',') ??
              productModel.tagIds?.join(','),
          itemListName: productModel.categoryName,
          data: widget.products,
        );

    /// only request to server if there is empty config params
    // / If there is config, load the products one
  }

  void _initFilter() {
    WidgetsBinding.instance.endOfFrame.then((_) async {
      await initFilter(config: productConfig);

      if (mounted) {
        _streamSubscription =
            eventBus.on<EventRefreshProductsList>().listen((event) {
          onRefresh();
        });
        resetFilter();
        await onRefresh();
      }
    });
  }

  @override
  void clearProductList() {
    productModel.setProductsList([]);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> getProductList({bool forceLoad = false}) async {
    await productModel.getProductsList(
      boostEngine: widget.config?.boostEngine,
      categoryId: categoryIds,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      lang: appModel.langCode,
      orderBy: filterSortBy.orderByType?.name,
      order: filterSortBy.orderType?.name,
      featured: filterSortBy.featured,
      onSale: filterSortBy.onSale,
      tagId: tagIds,
      attribute: attribute,
      attributeTerm: getAttributeTerm(),
      userId: userModel.user?.id,
      listingLocation: listingLocationId,
      include: include,
      search: search,
    );
  }

  ProductBackdrop backdrop({
    products,
    isFetching,
    errMsg,
    isEnd,
    width,
    required String layout,
  }) {
    return ProductBackdrop(
      backdrop: Backdrop(
        hasAppBar: hasAppBar,
        bgColor: productConfig.backgroundColor,
        frontLayer: layout.isListView
            ? ProductList(
                products: products,
                onRefresh: onRefresh,
                onLoadMore: onLoadMore,
                isFetching: isFetching,
                errMsg: errMsg,
                isEnd: isEnd,
                layout: layout,
                ratioProductImage: ratioProductImage,
                productListItemHeight: productListItemHeight,
                width: width,
              )
            : AsymmetricView(
                products: products,
                isFetching: isFetching,
                isEnd: isEnd,
                onLoadMore: onLoadMore,
                width: width),
        backLayer: BackdropMenu(
          onFilter: onFilter,
          categoryId: categoryIds,
          tagId: tagIds,
          sortBy: filterSortBy,
          listingLocationId: listingLocationId,
          onApply: onCloseFilter,
          allowMultipleCategory: allowMultipleCategory,
          allowMultipleTag: allowMultipleTag,
        ),
        frontTitle: productConfig.showCountDown
            ? Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentTitle),
                      CountDownTimer(widget.countdownDuration)
                    ],
                  ),
                ],
              )
            : Text(currentTitle),
        backTitle: Center(child: Text(S.of(context).filter)),
        controller: _controller,
        appbarCategory: ProductCategoryMenu(
          enableSearchHistory: widget.enableSearchHistory,
          selectedCategories: categoryIds,
          onTap: onTapProductCategoryMenu,
        ),
        onTapShareButton: () async {
          await shareProductsLink(context);
        },
      ),
      expandingBottomSheet: (Services().widget.enableShoppingCart(null) &&
              !ServerConfig().isListingType &&
              kAdvanceConfig.showBottomCornerCart)
          ? ExpandingBottomSheet(hideController: _controller)
          : null,
    );
  }

  void onTapProductCategoryMenu(String? categoryId) {
    include = null;
    if (categoryIds?.contains(categoryId) ?? false) {
      categoryIds?.remove(categoryId);
    } else if (categoryId != null) {
      if (allowMultipleCategory) {
        categoryIds?.add(categoryId);
      } else {
        categoryIds = [categoryId];
      }
    }
    onFilter(categoryId: categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    _currentTitle = productConfig.name ??
        productModel.categoryName ??
        S.of(context).results;

    Widget buildMain = LayoutBuilder(
      builder: (context, constraint) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: Selector<AppModel, String>(
            selector: (context, provider) => provider.productListLayout,
            builder: (context, productListLayout, child) {
              /// override the layout to listTile if enableSearchUX
              /// otherwise, using default productListLayout from the Config
              var layout = widget.enableSearchHistory
                  ? Layout.simpleList
                  : productListLayout;

              return ListenableProvider.value(
                value: productModel,
                child: Consumer<ProductModel>(
                  builder: (context, model, child) {
                    var backdropLayout = enableProductBackdrop;

                    if (!backdropLayout) {
                      return ProductFlatView(
                        searchFieldController: _searchFieldController,
                        hasAppBar: hasAppBar,
                        autoFocusSearch: widget.autoFocusSearch,
                        enableSearchHistory: widget.enableSearchHistory,
                        builder: layout.isListView
                            ? ProductList(
                                products: model.productsList,
                                onRefresh: onRefresh,
                                onLoadMore: onLoadMore,
                                isFetching: model.isFetching,
                                errMsg: model.errMsg,
                                isEnd: model.isEnd,
                                layout: layout,
                                ratioProductImage: ratioProductImage,
                                productListItemHeight: productListItemHeight,
                                width: constraint.maxWidth,
                                appbar: renderFilters(context),
                                header: [
                                  ProductCategoryMenu(
                                    imageLayout: true,
                                    enableSearchHistory:
                                        widget.enableSearchHistory,
                                    selectedCategories: categoryIds,
                                    onTap: onTapProductCategoryMenu,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        bottom: 10,
                                        top: 25),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              currentTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    height: 0.6,
                                                  ),
                                            ),
                                            const Spacer(),
                                            if ((model.productsList?.length ??
                                                    0) >
                                                0) ...[
                                              Text(
                                                '${model.productsList?.length} ${S.of(context).items}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                              ),
                                              const SizedBox(width: 5),
                                            ]
                                          ],
                                        ),
                                        if (productConfig.showCountDown) ...[
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                S
                                                    .of(context)
                                                    .endsIn('')
                                                    .toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.8),
                                                    )
                                                    .apply(fontSizeFactor: 0.6),
                                              ),
                                              CountDownTimer(
                                                  widget.countdownDuration),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : AsymmetricView(
                                products: model.productsList,
                                isFetching: model.isFetching,
                                isEnd: model.isEnd,
                                onLoadMore: onLoadMore,
                                width: constraint.maxWidth),
                        titleFilter:
                            layout.isListView ? null : renderFilters(context),
                        onFilter: onFilter,
                        onSearch: (String searchText) => {
                          onFilter(
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            categoryId: categoryIds,
                            tagId: tagIds,
                            listingLocationId: listingLocationId,
                            search: searchText,
                            isSearch: true,
                          )
                        },
                        bottomSheet: (Services()
                                    .widget
                                    .enableShoppingCart(null) &&
                                !ServerConfig().isListingType &&
                                showBottomCornerCart)
                            ? ExpandingBottomSheet(hideController: _controller)
                            : null,
                      );
                    }
                    return backdrop(
                      products: model.productsList,
                      isFetching: model.isFetching,
                      errMsg: model.errMsg,
                      isEnd: model.isEnd,
                      width: constraint.maxWidth,
                      layout: layout,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );

    buildMain = renderScaffold(
      routeName: widget.routeName ?? RouteList.backdrop,
      child: buildMain,
      resizeToAvoidBottomInset: false,
      disableSafeArea: true,
    );

    return kIsWeb
        ? WillPopScopeWidget(
            onWillPop: () async {
              eventBus.fire(const EventOpenCustomDrawer());
              // LayoutWebCustom.changeStateMenu(true);
              Navigator.of(context).pop();
              return false;
            },
            child: buildMain,
          )
        : buildMain;
  }

  @override
  String get lang => appModel.langCode;

  @override
  void onCategorySelected(String? name) {
    productModel.categoryName = name;
    _currentTitle = (name?.isNotEmpty ?? false) ? name! : S.of(context).results;
  }

  @override
  void onCloseFilter() {
    _controller.forward();
  }

  @override
  void rebuild() {
    setState(() {});
  }

  @override
  void onClearTextSearch() {
    _searchFieldController.clear();
  }
}

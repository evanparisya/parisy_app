import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralGray),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 1,
        title: Text(
          AppStrings.cart,
          style: TextStyle(
            color: Color(AppColors.neutralBlack),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [ProfileAppBarAction()],
      ),
      body: Consumer<CartController>(
        builder: (context, cartController, child) {
          if (cartController.items.isEmpty) {
            return EmptyStateWidget(message: AppStrings.emptyCart);
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartController.items.length,
                  itemBuilder: (context, index) {
                    final item = cartController.items[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(AppColors.neutralWhite),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(AppColors.neutralGray),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Product image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(AppColors.neutralGray),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.image_not_supported),
                          ),
                          SizedBox(width: 12),
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppColors.neutralBlack),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rp ${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(AppColors.primaryGreen),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cartController.updateQuantity(
                                          item.productId,
                                          item.quantity - 1,
                                        );
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(AppColors.neutralGray),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(Icons.remove, size: 14),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        cartController.updateQuantity(
                                          item.productId,
                                          item.quantity + 1,
                                        );
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(AppColors.neutralGray),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(Icons.add, size: 14),
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        cartController.removeItem(
                                          item.productId,
                                        );
                                      },
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Color(AppColors.errorRed),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Checkout section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(AppColors.neutralWhite),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.totalPrice,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(AppColors.neutralDarkGray),
                          ),
                        ),
                        Text(
                          'Rp ${cartController.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (cartController.errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(AppColors.errorRed).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Color(AppColors.errorRed),
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cartController.errorMessage ?? '',
                                style: TextStyle(
                                  color: Color(AppColors.errorRed),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (cartController.errorMessage != null)
                      SizedBox(height: 16),
                    PrimaryButton(
                      label: AppStrings.checkout,
                      onPressed: () {
                        _showCheckoutDialog(context);
                      },
                      isLoading: cartController.isCheckingOut,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pengiriman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.neutralBlack),
                    ),
                  ),
                  SizedBox(height: 20),
                  InputField(
                    label: 'Alamat',
                    hint: 'Masukkan alamat pengiriman',
                    controller: _addressController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField(
                    label: 'Nomor Telepon',
                    hint: 'Masukkan nomor telepon',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField(
                    label: 'Catatan (Opsional)',
                    hint: 'Tambahkan catatan',
                    controller: _notesController,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Batal',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Checkout',
                          onPressed: () async {
                            final result = await context
                                .read<CartController>()
                                .checkout(
                                  address: _addressController.text,
                                  phone: _phoneController.text,
                                  notes: _notesController.text,
                                );

                            if (result && mounted) {
                              final cartController = context
                                  .read<CartController>();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pesanan berhasil dibuat! ID: ${cartController.lastOrderId}',
                                  ),
                                  backgroundColor: Color(
                                    AppColors.successGreen,
                                  ),
                                ),
                              );
                              _addressController.clear();
                              _phoneController.clear();
                              _notesController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

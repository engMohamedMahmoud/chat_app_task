import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../firebase/firebase_db.dart';
import '../../../../widgets/custom_textformfield.dart';

void showBottomSheetAddNewContact(BuildContext context, TextEditingController editingController, String btnTitle) {
  showBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState ){
              return Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Enter Friend Email",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        IconButton.filled(
                            onPressed: () {},
                            icon: const Icon(Iconsax.scan_barcode))
                      ],
                    ),
                    CustomTextformfield(
                        textInputType: TextInputType.emailAddress,
                        isPassword: false,
                        labelName: "Email",
                        widget: const Icon(Iconsax.direct),
                        editingController: editingController),

                    const SizedBox( height: 16,),
                    ElevatedButton(
                        onPressed: () async {


                          if(editingController.text.isNotEmpty){
                            await FireDb().addNewContact(context, editingController.text).then((value){
                              setState ((){
                                editingController.clear();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:  Text("Added Successfully")));

                              });
                            }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:  Text("Please, check email")));
                            },);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer),
                        child:  Center(
                          child: Text(btnTitle),
                        ))
                  ],
                ),
              );
            });
      });
}
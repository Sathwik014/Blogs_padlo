import 'dart:io';
import 'package:blogs_pado/App/services/blog_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class Newblog extends StatefulWidget {
  const Newblog({super.key});

  @override
  State<Newblog> createState() => _NewblogState();
}

class _NewblogState extends State<Newblog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  quill.QuillController _quillController = quill.QuillController.basic();

  File? _imageFile;
  String _selectedCategory = 'Interns';
  DateTime _blogDate = DateTime.now();
  bool _isPinned = false;

  final _categories = ['Interns', 'Academics', 'Campus', 'Tech', 'Clubs'];
  final _categoryIcons = {
    'Interns': Icons.person_outline,
    'Academics': Icons.menu_book,
    'Campus': Icons.school_outlined,
    'Tech': Icons.computer,
    'Clubs': Icons.camera_outlined,
  };

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> saveBlog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final contentJson = _quillController.document.toDelta().toJson();

      await BlogService().createBlogWithContent(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        contentJson: contentJson,
        category: _selectedCategory,
        blogDate: _blogDate,
        isPinned: _isPinned,
        imageUrl: '', // You can later update this for image uploads
      );

      Navigator.pop(context); // Close loader
      Navigator.pop(context); // Go back
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d').format(_blogDate);

    return SafeArea(child:Scaffold(
      appBar: AppBar(
        title: const Text("New Blog"),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: saveBlog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: Colors.black,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(_categoryIcons[category], size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 6),
                              Text(category[0].toUpperCase() + category.substring(1)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                  Text(formattedDate, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),

            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
              ),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Blog Title'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: 'Description'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'Bold') _quillController.formatSelection(quill.Attribute.bold);
                      if (value == 'Italic') _quillController.formatSelection(quill.Attribute.italic);
                      if (value == 'Code') _quillController.formatSelection(quill.Attribute.codeBlock);
                      if (value == 'Heading') _quillController.formatSelection(quill.Attribute.h1);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Bold'), value: 'Bold'),
                      const PopupMenuItem(child: Text('Italic'), value: 'Italic'),
                      const PopupMenuItem(child: Text('Code'), value: 'Code'),
                      const PopupMenuItem(child: Text('Heading'), value: 'Heading'),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: pickImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
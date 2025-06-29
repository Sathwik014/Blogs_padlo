import 'dart:convert';
import 'package:blogs_pado/App/models/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

class EditBlogPage extends StatefulWidget {
  final BlogModel blog;
  const EditBlogPage({super.key, required this.blog});

  @override
  State<EditBlogPage> createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late quill.QuillController _quillController;

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

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.blog.title;
    _descController.text = widget.blog.description;
    _selectedCategory = widget.blog.category;
    _isPinned = widget.blog.pinned;

    final content = widget.blog.content;
    quill.Document doc;

    if (content is String) {
      try {
        doc = quill.Document.fromJson(jsonDecode(content as String));
      } catch (e) {
        doc = quill.Document();
      }
    } else if (content is List<dynamic>) {
      doc = quill.Document.fromJson(content);
    } else {
      doc = quill.Document();
    }

    _quillController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> saveBlog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final contentJson = _quillController.document.toDelta().toJson();

      final updatedBlog = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'content': contentJson,
        'timestamp': Timestamp.fromDate(_blogDate),
        'category': _selectedCategory,
        'pinned': _isPinned,
        'lastEdited': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blog.blogId)
          .update(updatedBlog);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d').format(_blogDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Blog"),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

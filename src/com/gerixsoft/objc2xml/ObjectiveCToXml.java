package com.gerixsoft.objc2xml;

import java.io.File;
import java.util.Arrays;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;

import org.xml.sax.InputSource;

import com.sun.xml.internal.bind.v2.runtime.unmarshaller.XsiNilLoader.Array;

public class ObjectiveCToXml {

	public static void main(String[] args) throws TransformerException {
		if (args.length != 2) {
			System.err.println("usage: <objc-source> <xml-result>");
			System.exit(-1);
		}
		File objcFile = new File(args[0]);
		File xmlFile = new File(args[1]);

		if (objcFile.isFile()) {
			objc2xml(objcFile, xmlFile);
		} else {
			File[] files = objcFile.listFiles();
			Arrays.sort(files);
			for (File file : files) {
				System.out.println(file);
				objc2xml(file, new File(xmlFile, file.getName() + ".xml"));
			}
		}
		System.out.println("ok");
	}

	public static void objc2xml(File objcFile, File xmlFile) throws TransformerException {
		Transformer transformer = TransformerFactory.newInstance().newTransformer();
		transformer.setOutputProperty("indent", "yes");
		transformer.transform(
				new SAXSource(new ObjectiveCSAXParser(), new InputSource(objcFile.toString())),
				new StreamResult(xmlFile));
	}
}

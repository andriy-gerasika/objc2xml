package com.gerixsoft.objc2xml;

import java.io.File;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;

import org.xml.sax.InputSource;

public class ObjectiveCToXml {

	public static void main(String[] args) throws TransformerException {
		if (args.length != 2) {
			System.err.println("usage: <input-objc-file-or-directory> <output-xml-file-or-directory>");
			System.exit(-1);
		}
		ObjectiveCToXml objc2xml = new ObjectiveCToXml();
		objc2xml.transformer.setOutputProperty("indent", "yes");
		objc2xml.transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
		objc2xml.transform(new File(args[0]), new File(args[1]));
		System.out.println("ok");
	}

	private Transformer transformer;

	public ObjectiveCToXml() throws TransformerConfigurationException {
		transformer = TransformerFactory.newInstance().newTransformer();
	}

	public void transform(File input, File output) throws TransformerException {
		if (input.isDirectory()) {
			output.mkdir();
			for (File child : input.listFiles()) {
				if (child.isDirectory()) {
					transform(child, new File(output, child.getName()));
				} else if (child.getName().endsWith(".h")) {
					transform(child, new File(output, child.getName().concat(".xml")));
				}
			}
			return;
		}
		transformer.transform(new SAXSource(new ObjectiveCSaxParser(), new InputSource(input.toString())), new StreamResult(output));
	}
}

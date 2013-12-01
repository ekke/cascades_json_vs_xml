/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/data/JsonDataAccess>
#include <bb/data/XmlDataAccess>

static QString dataPath(const QString& fileName) {
	return QDir::currentPath() + "/data/" + fileName;
}

static QString assetsXMLPath(const QString& fileName) {
	return QDir::currentPath() + "/app/native/assets/xml_data/" + fileName;
}

static QString assetsJSONPath(const QString& fileName) {
	return QDir::currentPath() + "/app/native/assets/json_data/" + fileName;
}

using namespace bb::cascades;
using namespace bb::data;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
		QObject(app) {
	// prepare the localization
	m_pTranslator = new QTranslator(this);
	m_pLocaleHandler = new LocaleHandler(this);

	bool res = QObject::connect(m_pLocaleHandler,
			SIGNAL(systemLanguageChanged()), this,
			SLOT(onSystemLanguageChanged()));
	// This is only available in Debug builds
	Q_ASSERT(res);
	// Since the variable is not used in the app, this is added to avoid a
	// compiler warning
	Q_UNUSED(res);

	// initial load
	onSystemLanguageChanged();

	// Create scene document from main.qml asset, the parent is set
	// to ensure the document gets destroyed properly at shut down.
	QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);

	// access to the Application
	qml->setContextProperty("app", this);

	// Create root object for the UI
	AbstractPane *root = qml->createRootObject<AbstractPane>();

	// Set created root object as the application scene
	app->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged() {
	QCoreApplication::instance()->removeTranslator(m_pTranslator);
	// Initiate, load and install the application translation files.
	QString locale_string = QLocale().name();
	QString file_name = QString("cascades_JSONvsXML_%1").arg(locale_string);
	if (m_pTranslator->load(file_name, "app/native/qm")) {
		QCoreApplication::instance()->installTranslator(m_pTranslator);
	}
}

void ApplicationUI::copyAssetsToData() {

}

void ApplicationUI::compareJSONandXMLspeaker() {
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	QString filenameXML;
	XmlDataAccess xda;
	QTime time;
	filenameXML = "speaker.xml";
	QFile dataFile2(assetsXMLPath(filenameXML));
	time.start();
	dataFile2.open(QIODevice::ReadOnly);
	data = xda.loadFromBuffer(dataFile2.readAll());
	int elapsed2 = time.elapsed();
	//
	filenameJSON = "speaker.json";
	QFile dataFile1(assetsJSONPath(filenameJSON));
	time.start();
	dataFile1.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile1.readAll());
	int elapsed1 = time.elapsed();
	//
	filenameJSON = "speakerlist.json";
	QFile dataFile3(assetsJSONPath(filenameJSON));
	time.start();
	dataFile3.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile3.readAll());
	int elapsed3 = time.elapsed();
	qDebug() << "1: READ JSON " << elapsed1 << " 2: READ XML " << elapsed2
			<< " 3: READ JSON converted " << elapsed3;
	int maxValue;
	maxValue = std::max(elapsed1, elapsed2);
	maxValue = std::max(maxValue, elapsed3);
	emit speedTestSpeaker(maxValue, elapsed2, elapsed1, elapsed3);
}

void ApplicationUI::compareJSONandXMLaddresses() {
	// attention: no checks done if file exists, could be read or written
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	QString filenameXML;
	XmlDataAccess xda;
	QTime time;

	// 3: READ XML
	filenameXML = "addresses_us.xml";
	QFile dataFile2(assetsXMLPath(filenameXML));
	time.start();
	dataFile2.open(QIODevice::ReadOnly);
	data = xda.loadFromBuffer(dataFile2.readAll());
	int elapsed3 = time.elapsed();
	// 4: WRITE XML
	filenameXML = "addresses_us.xml";
	time.start();
	xda.save(data, dataPath(filenameXML));
	int elapsed4 = time.elapsed();

	// 1: READ JSON
	filenameJSON = "addresses_us.json";
	QFile dataFile1(assetsJSONPath(filenameJSON));
	time.start();
	dataFile1.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile1.readAll());
	int elapsed1 = time.elapsed();
	// 2: WRITE JSON
	filenameJSON = "addresses_us.json";
	time.start();
	jda.save(data, dataPath(filenameJSON));
	int elapsed2 = time.elapsed();

	qDebug() << "1: READ JSON " << elapsed1 << " 2: WRITE JSON " << elapsed2
			<< " 3: READ XML " << elapsed3 << " 4: WRITE XML " << elapsed4;
	int maxValue;
	maxValue = std::max(elapsed1, elapsed2);
	maxValue = std::max(maxValue, elapsed3);
	maxValue = std::max(maxValue, elapsed4);
	emit speedTestAddresses(maxValue, elapsed1, elapsed2, elapsed3, elapsed4);
}

void ApplicationUI::convertJSONtoXMLAddresses() {
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	filenameJSON = "addresses_us.json";
	QFile dataFile(assetsJSONPath(filenameJSON));
	if (!dataFile.exists()) {
		// do something
		qWarning() << "addresses_us.json not found";
		return;
	}
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = jda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameJSON;
	}
	QString filenameXML;
	filenameXML = "addresses_us.xml";
	// QVariant data = xda.load
	XmlDataAccess xda;
	xda.save(data, dataPath(filenameXML));
	qDebug() << "finished converting";
}

void ApplicationUI::convertXMLtoJSONAddresses() {
	XmlDataAccess xda;
	QVariant data;
	QString filenameXML;
	filenameXML = "addresses_us.xml";
	QFile dataFile(assetsXMLPath(filenameXML));
	if (!dataFile.exists()) {
		// do something
		qWarning() << "addresses_us.xml not found";
		return;
	}
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = xda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameXML;
	}
	QString filenameJSON;
	filenameJSON = "addresses_us.json";
	// QVariant data = xda.load
	JsonDataAccess jda;
	jda.save(data, dataPath(filenameJSON));
	qDebug() << "finished converting";
}

void ApplicationUI::convertXMLtoJSONspeaker() {
	XmlDataAccess xda;
	QVariant data;
	QString filenameXML;
	filenameXML = "speaker.xml";
	QFile dataFileSpeaker(assetsXMLPath(filenameXML));
	if (!dataFileSpeaker.exists()) {
		// do something
		return;
	}
	bool ok = dataFileSpeaker.open(QIODevice::ReadOnly);
	if (ok) {
		data = xda.loadFromBuffer(dataFileSpeaker.readAll());
		dataFileSpeaker.close();
	} else {
		qDebug() << "cannot read data file: " << filenameXML;
	}
	// write the file without converting
	QString filenameJSON = "speaker.json";
	JsonDataAccess jda;
	jda.save(data, dataPath(filenameJSON));
	// now convert
	convertSpeaker(data);
	filenameJSON = "speakerlist.json";
	jda.save(data, dataPath(filenameJSON));
	qDebug() << "finished converting speaker";
}

void ApplicationUI::convertSpeaker(QVariant& data) {
	QVariantMap rootMap = data.toMap();
	QVariantMap channelMap = rootMap.value("channel").toMap();
	QVariantList itemList = channelMap.value("item").toList();
	QVariantList speakerList;
	for (int i = 0; i < itemList.size(); ++i) {
		QVariantMap itemMap = itemList.at(i).toMap();
		QVariantMap guidMap = itemMap.value("guid").toMap();
		QString guid = guidMap.value(".data").toString().split("=").last();
		int id = guid.toInt();
		QVariantList metaList = itemMap.value("wp:postmeta").toList();
		QVariantMap speakerMap;
		speakerMap.insert("id", id);
		speakerMap.insert("bio", itemMap.value("content:encoded"));
		speakerMap.insert("name", itemMap.value("title"));
		for (int m = 0; m < metaList.size(); ++m) {
			QVariantMap metaMap = metaList.at(m).toMap();
			QString metaKey = metaMap.value("wp:meta_key").toString();
			if (metaKey == "wpcf-speaker-company") {
				speakerMap.insert("company", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-intro") {
				speakerMap.insert("intro", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-xing") {
				speakerMap.insert("xing", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-blog") {
				speakerMap.insert("blog", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-foto") {
				speakerMap.insert("foto", metaMap.value("wp:meta_value"));
				continue;
			}
		}
		speakerList.append(speakerMap);
	}
	data = speakerList;
}

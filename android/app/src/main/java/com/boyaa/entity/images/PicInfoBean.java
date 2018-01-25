package com.boyaa.entity.images;

public class PicInfoBean {
	private String imageName;
	private String url;
	private boolean loaded = false;

	public boolean isLoaded() {
		return loaded;
	}

	public void setLoaded(boolean loaded) {
		this.loaded = loaded;
	}

	public PicInfoBean(String imageName, String url) {
		super();
		this.imageName = imageName;
		this.url = url;
	}

	public String getImageName() {
		return imageName;
	}

	public void setImageName(String imageName) {
		this.imageName = imageName;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}
}
